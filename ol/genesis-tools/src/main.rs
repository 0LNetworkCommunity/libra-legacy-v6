use backup_cli::storage::{FileHandle, FileHandleRef};
use serde::de::DeserializeOwned;
use std::{fs::File};

use std::io::Read;

use libra_types::{
    proof::TransactionInfoWithProof, ledger_info::LedgerInfoWithSignatures,
    account_state_blob::AccountStateBlob
};

use libra_crypto::HashValue;

use backup_cli::backup_types::state_snapshot::manifest::StateSnapshotBackup;
use anyhow::{ensure, Result};

use tokio::{
    fs::{OpenOptions},
    io::{AsyncRead}
};

use backup_cli::utils::read_record_bytes::ReadRecordBytes;
use futures::executor::block_on;


async fn open_for_read(
    file_handle: &FileHandleRef,
) -> Result<Box<dyn AsyncRead + Send + Unpin>> {
    let mut path: String = "/home/node/libra/ol/fixtures/state-snapshot/194/".to_owned();
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

fn read_from_json(path: &str) -> Result<StateSnapshotBackup>{
    let config = std::fs::read_to_string(path)?;
    let map: StateSnapshotBackup = serde_json::from_str(&config)?;
    Ok(map)
}

fn load_lcs_file<T: DeserializeOwned>(file_handle: &str) -> Result<T> {
    let x = read_from_file(&file_handle)?;
    Ok(lcs::from_bytes(&x)?)
}

async fn read_account_state_chunk(file_handle: FileHandle) -> Result<Vec<(HashValue, AccountStateBlob)>> {
    let mut file = open_for_read(&file_handle).await?;

    let mut chunk = vec![];

    while let Some(record_bytes) = file.read_record_bytes().await? {
        chunk.push(lcs::from_bytes(&record_bytes)?);
    }
    Ok(chunk)
}

async fn run_impl(manifest: StateSnapshotBackup) -> Result<()>{
    for chunk in manifest.chunks {
        let blobs = read_account_state_chunk(chunk.blobs).await?;
        let proof = load_lcs_file(&chunk.proof)?;
        println!("{:?}", blobs);
        println!("{:?}", proof);

    }
    Ok(())
}

fn main() -> Result<()>{
    // let the_file = r#"{
    //     "FirstName": "John",
    //     "LastName": "Doe",
    //     "Age": 43,
    //     "Address": {
    //         "Street": "Downing Street 10",
    //         "City": "London",
    //         "Country": "Great Britain"
    //     },
    //     "PhoneNumbers": [
    //         "+44 1234567",
    //         "+44 2345678"
    //     ]
    // }"#;

    let path = "/home/node/libra/ol/fixtures/state-snapshot/194/state_ver_74694920.0889/state.manifest";
    let path2 = "/home/node/libra/ol/fixtures/state-snapshot/194/state_ver_74694920.0889/state.proof";

    // let file = File::open(path)
    //     .expect("file should open read only");

    
    // let json: serde_json::Value = serde_json::from_reader(file)
    //     .expect("file should be proper JSON");
    // let first_name = json.get("version")
    //     .expect("file should have FirstName key");
    // println!("{:?}", json);
    // println!("{:?}", first_name);

    // let x = read_from_file(path);
    // println!("{:?}", x);

    let manifest = read_from_json(&path).unwrap();
    // println!("{:?}", y.version);


    // let first_name = json.get("version")
    //     .expect("file should have FirstName key");

    // let manifest: StateSnapshotBackup = json
    // println!("{:?}", json);
    // println!("{:?}", first_name);
    

    // let json: serde_json::Value =
    //     serde_json::from_str(the_file).expect("JSON was not well-formatted");
    // println!("{:?}", json)

    // let y = read_from_file(path2);

    let (txn_info_with_proof, li): (TransactionInfoWithProof, LedgerInfoWithSignatures) = load_lcs_file(path2).unwrap();

    // println!("{:?}", txn_info_with_proof);
    // println!("{:?}", li);

    txn_info_with_proof.verify(li.ledger_info(), manifest.version)?;

    ensure!(
        txn_info_with_proof.transaction_info().state_root_hash() == manifest.root_hash,
        "Root hash mismatch with that in proof. root hash: {}, expected: {}",
        manifest.root_hash,
        txn_info_with_proof.transaction_info().state_root_hash(),
    );

    let future = run_impl(manifest); // Nothing is printed
    block_on(future)?;

    Ok(())
    
}