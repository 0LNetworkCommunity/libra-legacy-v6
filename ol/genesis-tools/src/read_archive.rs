//! read-archive

use backup_cli::storage::{FileHandle, FileHandleRef};
use libra_types::access_path::AccessPath;
use libra_types::account_config::AccountResource;
use libra_types::account_state::AccountState;

use libra_types::write_set::{WriteOp, WriteSetMut};
use move_core_types::move_resource::MoveResource;
use ol_fixtures::get_persona_mnem;
use ol_keys::wallet::get_account_from_mnem;
use serde::de::DeserializeOwned;
use std::convert::TryFrom;
use std::path::PathBuf;

use std::fs::File;

use std::io::Read;

use libra_config::utils::get_available_port;
use libra_crypto::HashValue;
use libra_types::{
    account_state_blob::AccountStateBlob, ledger_info::LedgerInfoWithSignatures,
    proof::TransactionInfoWithProof,
};
use libra_types::{
    transaction::{Transaction, WriteSetPayload},
    trusted_state::TrustedState,
    waypoint::Waypoint,
};
use std::{
    net::{IpAddr, Ipv4Addr, SocketAddr},
    sync::Arc,
};

use backup_cli::backup_types::state_snapshot::manifest::StateSnapshotBackup;

use anyhow::{bail, ensure, Error, Result};

use tokio::{fs::OpenOptions, io::AsyncRead};

use libra_temppath::TempPath;
use libradb::LibraDB;

use backup_cli::utils::read_record_bytes::ReadRecordBytes;

use backup_service::start_backup_service;
use tokio::runtime::Runtime;

use executor::db_bootstrapper::{generate_waypoint, maybe_bootstrap};
use libra_vm::LibraVM;
use storage_interface::DbReaderWriter;

use crate::generate_genesis;
use crate::recover::{LegacyRecovery, accounts_into_recovery, save_recovery_file};

fn get_runtime() -> (Runtime, u16) {
    let port = get_available_port();
    let path = TempPath::new();
    let rt = start_backup_service(
        SocketAddr::new(IpAddr::V4(Ipv4Addr::LOCALHOST), port),
        Arc::new(LibraDB::new_for_test(&path)),
    );
    (rt, port)
}

async fn open_for_read(file_handle: &FileHandleRef) -> Result<Box<dyn AsyncRead + Send + Unpin>> {
    let home = dirs::home_dir().unwrap();
    let mut path: String = home
        .join("libra/ol/fixtures/state-snapshot/194/")
        .into_os_string()
        .into_string()
        .unwrap()
        .to_owned();
    path.push_str(&file_handle.to_string());
    let file = OpenOptions::new().read(true).open(path).await?;
    Ok(Box::new(file))
}

fn read_from_file(path: &str) -> Result<Vec<u8>> {
    let mut data = Vec::<u8>::new();
    let mut f = File::open(path).expect("Unable to open file");
    f.read_to_end(&mut data).expect("Unable to read data");
    // println!("{}", data.len())?;
    Ok(data)
}

fn read_from_json(path: &PathBuf) -> Result<StateSnapshotBackup> {
    let config = std::fs::read_to_string(path)?;
    let map: StateSnapshotBackup = serde_json::from_str(&config)?;
    Ok(map)
}

fn load_lcs_file<T: DeserializeOwned>(file_handle: &str) -> Result<T> {
    let x = read_from_file(&file_handle)?;
    Ok(lcs::from_bytes(&x)?)
}

async fn read_account_state_chunk(
    file_handle: FileHandle,
) -> Result<Vec<(HashValue, AccountStateBlob)>> {
    let mut file = open_for_read(&file_handle).await?;

    let mut chunk = vec![];

    while let Some(record_bytes) = file.read_record_bytes().await? {
        chunk.push(lcs::from_bytes(&record_bytes)?);
    }
    Ok(chunk)
}

/// take an archive file path and parse into a writeset
pub async fn archive_into_writeset(
    archive_path: PathBuf,
    case: GenesisCase,
) -> Result<WriteSetMut, Error> {
    let backup = read_from_json(&archive_path)?;
    let account_blobs = accounts_from_snapshot_backup(backup).await?;
    accounts_into_writeset(&account_blobs, case)
}

/// take an archive file path and parse into a writeset
pub async fn archive_into_recovery(
    archive_path: &PathBuf,
    recovery_path: &PathBuf,
) -> Result<Vec<LegacyRecovery>, Error> {
    let backup = read_from_json(archive_path)?;
    let account_blobs = accounts_from_snapshot_backup(backup).await?;
    let r = accounts_into_recovery(&account_blobs)?;
    save_recovery_file(&r, recovery_path)?;
    Ok(r)
}

/// Tokio async parsing of state snapshot into blob
async fn accounts_from_snapshot_backup(
    manifest: StateSnapshotBackup,
) -> Result<Vec<AccountStateBlob>> {
    // parse AccountStateBlob from chunks of the archive
    let mut account_state_blobs: Vec<AccountStateBlob> = Vec::new();
    for chunk in manifest.chunks {
        let blobs = read_account_state_chunk(chunk.blobs).await?;
        // println!("{:?}", blobs);
        for (_key, blob) in blobs {
            account_state_blobs.push(blob)
        }
    }

    Ok(account_state_blobs)
}

fn get_alice_authkey_for_swarm() -> Vec<u8> {
    let mnemonic_string = get_persona_mnem("alice");
    let account_details = get_account_from_mnem(mnemonic_string);
    account_details.0.to_vec()
}

/// cases that we need to create a genesis from backup.
pub enum GenesisCase {
    /// a network upgrade or fork
    Fork,
    /// simulate state in a local swarm.
    Test,
}

/// make the writeset for the genesis case. Starts with an unmodified account state and make into a writeset.
pub fn accounts_into_writeset(
    account_state_blobs: &Vec<AccountStateBlob>,
    case: GenesisCase,
) -> Result<WriteSetMut, Error> {
    let mut write_set_mut = WriteSetMut::new(vec![]);
    for blob in account_state_blobs {
        let account_state = AccountState::try_from(blob)?;
        match case {
            GenesisCase::Fork => todo!(),
            GenesisCase::Test => {
                // TODO: borrow
                let clean = get_unmodified_writeset(&account_state)?;
                let auth =
                    authkey_rotate_change_item(&account_state, get_alice_authkey_for_swarm())?;
                let merge_clean = merge_writeset(write_set_mut, clean)?;
                let merge_all = merge_writeset(merge_clean, auth)?;

                return Ok(merge_all);
            }
        }
    }
    println!("Total accounts read: {}", &account_state_blobs.len());

    Ok(write_set_mut)
}

/// Without modifying the data convert an AccountState struct, into a WriteSet Item which can be included in a genesis transaction. This should take all of the resources in the account.
fn get_unmodified_writeset(account_state: &AccountState) -> Result<WriteSetMut, Error> {
    let mut ws = WriteSetMut::new(vec![]);
    if let Some(address) = account_state.get_account_address()? {
        // iterate over all the account's resources\
        for (k, v) in account_state.iter() {
            let item_tuple = (
                AccessPath::new(address, k.clone()),
                WriteOp::Value(v.clone()),
            );
            // push into the writeset
            ws.push(item_tuple);
        }
        println!("processed account: {:?}", address);

        return Ok(ws);
    }

    bail!("ERROR: No address for AccountState: {:?}", account_state);
}

/// Returns the writeset item for replaceing an authkey on an account. This is only to be used in testing and simulation.
fn authkey_rotate_change_item(
    account_state: &AccountState,
    authentication_key: Vec<u8>,
) -> Result<WriteSetMut, Error> {
    let mut ws = WriteSetMut::new(vec![]);

    if let Some(address) = account_state.get_account_address()? {
        // iterate over all the account's resources
        for (k, _v) in account_state.iter() {
            // if we find an AccountResource struc, which is where authkeys are kept
            if k.clone() == AccountResource::resource_path() {
                // let account_resource_option = account_state.get_account_resource()?;
                if let Some(account_resource) = account_state.get_account_resource()? {
                    let account_resource_new = account_resource
                        .clone_with_authentication_key(authentication_key.clone(), address.clone());
                    ws.push((
                        AccessPath::new(address, k.clone()),
                        WriteOp::Value(lcs::to_bytes(&account_resource_new).unwrap()),
                    ));
                }
            }
        }
        println!("rotate authkey for account: {:?}", address);
    }
    bail!(
        "ERROR: No address found at AccountState: {:?}",
        account_state
    );
}

/// helper to merge writesets
pub fn merge_writeset(mut left: WriteSetMut, right: WriteSetMut) -> Result<WriteSetMut, Error> {
    left.write_set.extend(right.write_set);
    Ok(left)
}

/// Tokio async parsing of state snapshot into blob
async fn run_impl(manifest: StateSnapshotBackup) -> Result<()> {
    // parse AccountStateBlob from chunks of the archive
    let mut account_state_blobs: Vec<AccountStateBlob> = Vec::new();
    for chunk in manifest.chunks {
        let blobs = read_account_state_chunk(chunk.blobs).await?;
        // let proof = load_lcs_file(&chunk.proof)?;
        println!("{:?}", blobs);
        // TODO(Venkat) -> Here's the blob
        // println!("{:?}", proof);
        for (_key, blob) in blobs {
            account_state_blobs.push(blob)
        }
    }

    let genesis = vm_genesis::test_genesis_change_set_and_validators(Some(1));
    let genesis_txn = Transaction::GenesisTransaction(WriteSetPayload::Direct(genesis.0));
    let tmp_dir = TempPath::new();
    let db_rw = DbReaderWriter::new(LibraDB::new_for_test(&tmp_dir));

    // Executor won't be able to boot on empty db due to lack of StartupInfo.
    assert!(db_rw.reader.get_startup_info().unwrap().is_none());

    // Bootstrap empty DB.
    let waypoint = generate_waypoint::<LibraVM>(&db_rw, &genesis_txn).expect("Should not fail.");
    maybe_bootstrap::<LibraVM>(&db_rw, &genesis_txn, waypoint).unwrap();
    let startup_info = db_rw
        .reader
        .get_startup_info()
        .expect("Should not fail.")
        .expect("Should not be None.");
    assert_eq!(
        Waypoint::new_epoch_boundary(startup_info.latest_ledger_info.ledger_info()).unwrap(),
        waypoint
    );
    let (li, epoch_change_proof, _) = db_rw.reader.get_state_proof(waypoint.version()).unwrap();
    let trusted_state = TrustedState::from(waypoint);
    trusted_state
        .verify_and_ratchet(&li, &epoch_change_proof)
        .unwrap();

    // `maybe_bootstrap()` does nothing on non-empty DB.
    assert!(!maybe_bootstrap::<LibraVM>(&db_rw, &genesis_txn, waypoint).unwrap());

    let genesis_txn =
        generate_genesis::generate_genesis_from_snapshot(&account_state_blobs, &db_rw).unwrap();
    generate_genesis::write_genesis_blob(genesis_txn)?;
    generate_genesis::test_genesis_from_blob(&account_state_blobs, db_rw)?;
    Ok(())
}

/// given a path to state archive, produce a genesis.blob
pub fn genesis_from_path(path: PathBuf) -> Result<()> {
    let path_man = path.clone().join("state.manifest");
    dbg!(&path_man);
    let path_proof = path.join("state.proof");
    dbg!(&path_proof);

    let manifest = read_from_json(&path_man).unwrap();

    // Tokio runtime
    let (mut rt, _port) = get_runtime();

    let (txn_info_with_proof, li): (TransactionInfoWithProof, LedgerInfoWithSignatures) =
        load_lcs_file(&path_proof.into_os_string().into_string().unwrap()).unwrap();

    txn_info_with_proof.verify(li.ledger_info(), manifest.version)?;

    ensure!(
        txn_info_with_proof.transaction_info().state_root_hash() == manifest.root_hash,
        "Root hash mismatch with that in proof. root hash: {}, expected: {}",
        manifest.root_hash,
        txn_info_with_proof.transaction_info().state_root_hash(),
    );

    let future = run_impl(manifest); // Nothing is printed
    rt.block_on(future)?;

    Ok(())
}

#[test]
fn test_main() -> Result<()> {
    use std::path::Path;

    let path = env!("CARGO_MANIFEST_DIR");
    let buf = Path::new(path)
        .parent()
        .unwrap()
        .join("fixtures/state-snapshot/194/state_ver_74694920.0889/");
    genesis_from_path(buf)
}
