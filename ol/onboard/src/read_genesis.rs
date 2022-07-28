//! read genesis

use anyhow::Error;
use diem_types::transaction::Transaction;
use std::{fs::File, io::Read, path::PathBuf};

/// deserialize a genesis.blob in to a Transaction type
pub fn gen_tx_from_blob(genesis_path: &PathBuf) -> Result<Transaction, Error> {
    let mut file = File::open(genesis_path)?;
    let mut buffer = vec![];
    file.read_to_end(&mut buffer)?;
    Ok(bcs::from_bytes(&buffer)?)
}
