//! `save tx`
use std::{fs, io::Write};

use libra_types::{
    chain_id::ChainId,
    transaction::{helpers::create_user_txn, Script, SignedTransaction, TransactionPayload},
};

use crate::submit_tx::TxParams;
use anyhow::Error;

/// Submit a miner transaction to the network.
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

pub fn save_tx(script: Script, tx_params: TxParams) {
    match sign_tx(script, tx_params) {
        Ok(signed_tx) => {
            let mut file = fs::File::create("/root/signed_tx.json").unwrap();
            let j = serde_json::to_vec(&signed_tx).expect("could not serialize tx to json");
            file.write_all(&j)
                .expect("Could not write json");
            println!("Signed tx: {:?}", signed_tx);
        }
        Err(e) => {
            println!("Could not write tx: {:?}", e);
        }
    }
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
    // use libra_types::account_address::AccountAddress;
    let script = transaction_builder::encode_demo_e2e_script(42);

    save_tx(script, TxParams::test_fixtures());

    // assert_eq!(
    //   signed.sender(),
    //   "4C613C2F4B1E67CA8D98A542EE3F59F5"
    //     .parse::<AccountAddress>()
    //     .unwrap()
    // );
}
