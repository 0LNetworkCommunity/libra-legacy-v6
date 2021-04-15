//! `save tx`
use std::{
  fs::{self, File},
  io::{BufReader, Write},
  path::PathBuf,
};
use anyhow::Error;
use libra_types::transaction::SignedTransaction;


/// Save signed transaction to file
pub fn save_tx(txn: SignedTransaction, path: PathBuf) {
  let mut file = fs::File::create(path).unwrap();
  file.write_all(&serialize_txn(txn)).expect("Could not write json");
}

/// return the bytes of a signed transaction
pub fn serialize_txn(txn: SignedTransaction) -> Vec<u8> {
  serde_json::to_vec(&txn).expect("could not serialize tx to json")
}

/// deserializes the SignedTransaction from json file
pub fn read_tx_from_file(path: PathBuf) -> Result<SignedTransaction, Error> {
  // Open the file in read-only mode with buffer.
  let file = File::open(path)?;
  let reader = BufReader::new(file);

  let tx: SignedTransaction = serde_json::from_reader(reader)?;
  Ok(tx)
}
#[test]
fn test_sign_tx() {
  use libra_types::account_address::AccountAddress;
  use crate::submit_tx::TxParams;
  use crate::sign_tx::sign_tx;

  let script = transaction_builder::encode_demo_e2e_script(42);

  let signed = sign_tx(
    script,
    &TxParams::test_fixtures(),
    1,
    ChainId::new(1)
  ).unwrap();
  assert_eq!(
    signed.sender(),
    "4C613C2F4B1E67CA8D98A542EE3F59F5"
      .parse::<AccountAddress>()
      .unwrap()
  );
}

#[test]
fn test_save_tx() {
  use libra_types::account_address::AccountAddress;
  use crate::submit_tx::TxParams;
  use crate::sign_tx::sign_tx;

  let script = transaction_builder::encode_demo_e2e_script(42);
  let test_path = PathBuf::from("./signed_tx.json");
  let txn = sign_tx(script, &TxParams::test_fixtures()).unwrap();
  save_tx(txn, test_path.clone());

  let deserialized = read_tx_from_file(test_path.clone()).unwrap();
  assert_eq!(
    deserialized.sender(),
    "4C613C2F4B1E67CA8D98A542EE3F59F5"
      .parse::<AccountAddress>()
      .unwrap()
  );
  fs::remove_file(test_path).unwrap();
}
