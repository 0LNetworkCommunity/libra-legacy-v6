//! `relay`

#![forbid(unsafe_code)]
use crate::{config::TxsConfig, entrypoint::{self, EntryPointTxsCmd}, prelude::app_config, submit_tx::TxParams};
use anyhow::Error;
use abscissa_core::{ status_warn, status_ok};
use cli::{libra_client::LibraClient, AccountData, AccountStatus};
use libra_crypto::{
    test_utils::KeyPair,
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey}
};
use libra_genesis_tool::keyscheme::KeyScheme;
use libra_json_rpc_types::views::{TransactionView, VMStatusView};
use libra_types::{
    account_address::AccountAddress, waypoint::Waypoint, 
    transaction::helpers::*, chain_id::ChainId
};
use libra_types::transaction::{
    Script, TransactionPayload, authenticator::AuthenticationKey
};

use reqwest::Url;
use std::{fs, io::{stdout, Write}, path::{PathBuf}, thread, time};
use ol_util;

/// submit a previously signed tx, perhaps to be submitted by a different account than the signer account.
pub fn relay_tx(
    tx_params: &TxParams,
    script: Script,
) -> Result<TransactionView, Error> {
    let mut client = LibraClient::new(
        tx_params.url.clone(), tx_params.waypoint
    ).unwrap();

    let chain_id = ChainId::new(client.get_metadata().unwrap().chain_id);
    let (account_state,_) = client.get_account(
        tx_params.signer_address.clone(), true
    ).unwrap();

    let sequence_number = match account_state {
        Some(av) => av.sequence_number,
        None => 0,
    };
    // Sign the transaction script
    let txn = create_user_txn(
        &tx_params.keypair,
        TransactionPayload::Script(script),
        tx_params.signer_address,
        sequence_number,
        tx_params.max_gas_unit_for_tx,
        tx_params.coin_price_per_unit,
        "GAS".parse()?,
        // for compatibility with UTC's timestamp
        tx_params.user_tx_timeout as i64, 
        chain_id,
    )?;

    // Get account_data struct
    let mut signer_account_data = AccountData {
        address: tx_params.signer_address,
        authentication_key: Some(tx_params.auth_key.to_vec()),
        key_pair: Some(tx_params.keypair.clone()),
        sequence_number,
        status: AccountStatus::Persisted,
    };
    
    // Submit the transaction with libra_client
    match client.submit_transaction(
        Some(&mut signer_account_data),
        txn
    ){
        Ok(_) => {
            match wait_for_tx(
                tx_params.signer_address, sequence_number, &mut client
            ) {
                Some(res) => Ok(res),
                None => Err(Error::msg("No Transaction View returned"))
            }
        }
        Err(err) => Err(err)
    }

}