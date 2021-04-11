//! `save tx`
use std::{
  fs::{self, File},
  io::{BufReader, Write},
  path::PathBuf,
};

use libra_types::{
  chain_id::ChainId,
  transaction::{helpers::create_user_txn, Script, SignedTransaction, TransactionPayload},
};

use crate::submit_tx::TxParams;
use anyhow::Error;

/// sign a raw transaction script, and return a SignedTransaction
pub fn sign_tx(script: Script, tx_params: TxParams) -> Result<SignedTransaction, Error> {
  let chain_id = ChainId::new(1);
  // TODO, how does Alice get Bob's tx sequence number?
  // sign the transaction script
  create_user_txn(
    &tx_params.keypair,
    TransactionPayload::Script(script),
    tx_params.signer_address,
    1,
    tx_params.max_gas_unit_for_tx,
    tx_params.coin_price_per_unit,
    "GAS".parse().unwrap(),
    tx_params.user_tx_timeout as i64, // for compatibility with UTC's timestamp.
    chain_id,
  )
}

/// Save signed transaction to file
pub fn save_tx(script: Script, tx_params: TxParams, path: PathBuf) {
  match serialize_tx(script, tx_params) {
    Ok(ser) => {
      let mut file = fs::File::create(path).unwrap();
      file.write_all(&ser).expect("Could not write json");
    }
    Err(_) => {}
  }
}

/// return the bytes of a signed transaction
pub fn serialize_tx(script: Script, tx_params: TxParams) -> Result<Vec<u8>, Error> {
  match sign_tx(script, tx_params) {
    Ok(signed_tx) => {
      Ok(serde_json::to_vec(&signed_tx).expect("could not serialize tx to json"))
    }
    Err(e) => Err(e),
  }
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
  let script = transaction_builder::encode_demo_e2e_script(42);

  let signed = sign_tx(script, TxParams::test_fixtures()).unwrap();
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
  let script = transaction_builder::encode_demo_e2e_script(42);
  let test_path = PathBuf::from("./signed_tx.json");
  save_tx(script, TxParams::test_fixtures(), test_path.clone());

  let deserialized = read_tx_from_file(test_path).unwrap();
  assert_eq!(
    deserialized.sender(),
    "4C613C2F4B1E67CA8D98A542EE3F59F5"
      .parse::<AccountAddress>()
      .unwrap()
  );
  fs::remove_file(test_path);
}
