//! process-snapshot

use crate::{
    read_snapshot::{self},
    recover::{accounts_into_recovery, LegacyRecovery},
};
use anyhow::{bail, Error, Result};
use backup_cli::backup_types::state_snapshot::manifest::StateSnapshotBackup;
use diem_types::{access_path::AccessPath, account_config::{AccountResource}, account_state::AccountState, account_state_blob::AccountStateBlob, write_set::{WriteOp, WriteSetMut}};
use move_core_types::move_resource::MoveResource;
use ol_fixtures::get_persona_mnem;
use ol_keys::wallet::get_account_from_mnem;
use std::convert::TryFrom;
use std::path::PathBuf;

/// take an archive file path and parse into a writeset
pub async fn archive_into_swarm_writeset(archive_path: PathBuf) -> Result<WriteSetMut, Error> {
    let backup = read_snapshot::read_from_json(&archive_path)?;
    let account_blobs = accounts_from_snapshot_backup(backup, &archive_path).await?;
    accounts_into_writeset_swarm(&account_blobs)
}

/// take an archive file path and parse into a writeset
pub async fn archive_into_recovery(archive_path: &PathBuf) -> Result<Vec<LegacyRecovery>, Error> {
    let manifest_json = archive_path.join("state.manifest");

    let backup = read_snapshot::read_from_json(&manifest_json)?;

    let account_blobs = accounts_from_snapshot_backup(backup, archive_path).await?;
    let r = accounts_into_recovery(&account_blobs)?;
    Ok(r)
}

/// Tokio async parsing of state snapshot into blob
async fn accounts_from_snapshot_backup(
    manifest: StateSnapshotBackup,
    archive_path: &PathBuf,
) -> Result<Vec<AccountStateBlob>, Error> {
    // parse AccountStateBlob from chunks of the archive
    let mut account_state_blobs: Vec<AccountStateBlob> = Vec::new();
    for chunk in manifest.chunks {
        // dbg!(&archive_path);
        let blobs = read_snapshot::read_account_state_chunk(chunk.blobs, archive_path).await?;
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

/// make the writeset for the genesis case. Starts with an unmodified account state and make into a writeset.
fn accounts_into_writeset_swarm(
    account_state_blobs: &Vec<AccountStateBlob>,
) -> Result<WriteSetMut, Error> {
    let mut write_set_mut = WriteSetMut::new(vec![]);
    for blob in account_state_blobs {
        let account_state = AccountState::try_from(blob)?;
        // TODO: borrow
        let clean = get_unmodified_writeset(&account_state)?;
        let auth = authkey_rotate_change_item(&account_state, get_alice_authkey_for_swarm())?;
        let merge_clean = merge_writeset(write_set_mut, clean)?;
        write_set_mut = merge_writeset(merge_clean, auth)?;
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

                  let ar = account_resource.rotate_auth_key(authentication_key.clone());

                  ws.push((
                        AccessPath::new(address, k.clone()),
                        WriteOp::Value(bcs::to_bytes(&ar).unwrap()),
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
pub fn merge_writeset(left: WriteSetMut, right: WriteSetMut) -> Result<WriteSetMut, Error> {
    let mut merge = left.get();
    merge.extend(right.get());
    Ok(WriteSetMut::new(merge))
}

#[test]
pub fn test_accounts_into_recovery() {
    use diem_types::{account_config::BalanceResource, validator_config::ValidatorConfigResource};
    use move_core_types::move_resource::MoveResource;
    use ol_types::miner_state::MinerStateResource;

    use std::path::Path;

    let path = env!("CARGO_MANIFEST_DIR");
    let buf = Path::new(path)
        .parent()
        .unwrap()
        .join("fixtures/state-snapshot/194/state_ver_74694920.0889/");
    let path_man = buf.clone().join("state.manifest");
    println!("Running.....");
    let backup = crate::read_snapshot::read_from_json(&path_man).unwrap();

    let account_blobs_futures = accounts_from_snapshot_backup(backup, &path_man);
    let account_blobs = tokio_test::block_on(account_blobs_futures).unwrap();
    let genesis_recovery_list = accounts_into_recovery(&account_blobs).unwrap();
    println!(
        "Total GenesisRecovery objects: {}",
        &genesis_recovery_list.len()
    );
    for blob in account_blobs {
        let account_state = AccountState::try_from(&blob).unwrap();
        if let Some(address) = account_state.get_account_address().unwrap() {
            let mut address_processed = false;
            for gr in &genesis_recovery_list {
                if gr.account != Some(address) {
                    continue;
                }
                // iterate over all the account's resources\
                for (k, v) in account_state.iter() {
                    // extract the validator config resource
                    if k.clone() == BalanceResource::resource_path() {
                        match &gr.balance {
                            Some(balance) => {
                                if bcs::to_bytes(&balance).unwrap() != v.clone() {
                                    panic!("Balance resource not found in GenesisRecovery object: {:?}", gr.account);
                                }
                            }
                            None => {
                                panic!("Balance not found");
                            }
                        }
                    }
                    if k.clone() == ValidatorConfigResource::resource_path() {
                        match &gr.val_cfg {
                            Some(val_cfg) => {
                                if bcs::to_bytes(&val_cfg).unwrap() != v.clone() {
                                    panic!("ValidatorConfigResource not found in GenesisRecovery object: {:?}", gr.account);
                                }
                            }
                            None => {
                                panic!("ValidatorConfigResource not found");
                            }
                        }
                    }
                    if k.clone() == MinerStateResource::resource_path() {
                        match &gr.miner_state {
                            Some(miner_state) => {
                                if bcs::to_bytes(&miner_state).unwrap() != v.clone() {
                                    panic!("MinerStateResource not found in GenesisRecovery object: {:?}", gr.account);
                                }
                            }
                            None => {
                                panic!("MinerStateResource not found");
                            }
                        }
                    }
                }
                println!("processed account: {:?}", address);
                address_processed = true;
                break;
            }
            if !address_processed {
                panic!("Address not found for {} in recovery list", &address);
            }
        };
    }
}
