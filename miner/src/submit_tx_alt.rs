//! OlMiner submit_tx module
#![forbid(unsafe_code)]
use libra_types::{waypoint::Waypoint};
use crate::config::OlMinerConfig;
use crate::prelude::*;
use abscissa_core::{Command, Options, Runnable};

use libra_types::{account_address::AccountAddress, transaction::authenticator::AuthenticationKey};
use libra_crypto::{
    test_utils::KeyPair,
    PrivateKey,
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey}
};
// use libra_crypto::test_utils::KeyPair;
use anyhow::Error;
use cli::{libra_client::LibraClient, AccountData, AccountStatus};
use reqwest::Url;
use std::{thread, path::PathBuf, time, fs, io::{stdout, BufReader, Write}};
use libra_config::config::NodeConfig;
use libra_types::transaction::{Script, TransactionArgument, TransactionPayload};
use libra_types::{transaction::helpers::*, vm_error::StatusCode};
use crate::delay::delay_difficulty;
use stdlib::transaction_scripts;
use crate::block::build_block::{parse_block_height, mine_genesis, mine_once};
use libra_json_rpc_types::views::TransactionView;

pub struct TxParams {
    pub auth_key: AuthenticationKey,
    pub address: AccountAddress,
    pub url: Url,
    pub waypoint: Waypoint,
    pub keypair: KeyPair<Ed25519PrivateKey, Ed25519PublicKey>,//KeyPair,
    pub max_gas_unit_for_tx: u64,
    pub coin_price_per_unit: u64,
    pub user_tx_timeout: u64, // for compatibility with UTC's timestamp.
}

pub fn submit_tx(tx_params: &TxParams, preimage: Vec<u8>, proof: Vec<u8>, tower_height: u64) -> Result<Option<TransactionView>, Error> {
    
    thread::sleep(time::Duration::from_millis(24000));

    // Create a client object
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let account_state = client.get_account_state(tx_params.address.clone(), true).unwrap();
    dbg!(&account_state);


    let mut sequence_number = 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }
    println!("Onchain sequence number: {}", sequence_number);

    // Create the unsigned MinerState transaction script
    let script = Script::new(
        transaction_scripts::StdlibScript::Redeem.compiled_bytes().into_vec(),
        vec![],
        vec![
            TransactionArgument::U8Vector(preimage),
            TransactionArgument::U64(delay_difficulty()),
            TransactionArgument::U8Vector(proof),
            TransactionArgument::U64(tower_height as u64),
        ],
    );

    // sign the transaction script
    let txn = create_user_txn(
        &tx_params.keypair,
        TransactionPayload::Script(script),
        tx_params.address,
        sequence_number,
        tx_params.max_gas_unit_for_tx,
        tx_params.coin_price_per_unit,
        "GAS".parse()?,
        tx_params.user_tx_timeout as i64, // for compatibility with UTC's timestamp.
    )?;

    // get account_data struct
    let mut sender_account_data = AccountData {
        address: tx_params.address,
        authentication_key: Some(tx_params.auth_key.to_vec()),
        key_pair: Some(tx_params.keypair.clone()),
        sequence_number,
        status: AccountStatus::Persisted,
    };

    // dbg!(&sender_account_data);
    
    // Submit the transaction with libra_client
    match client.submit_transaction(
        Some(&mut sender_account_data),
        txn
    ){
        Ok(_) => {
            // TODO: There's a bug with requesting transaction state on the first sequence number. Don't skip the transaction view for first block submitted, fix the bug.
            println!("Transacation submitted to network, waiting for status.");
            match wait_for_tx(tx_params.address, sequence_number, &mut client){
                Ok(tx_view) => Ok(Some(tx_view)),
                Err(err) => Err(err)
            }
        }
        Err(err) => Err(err)
    }
}


pub fn wait_for_tx (
    sender_address: AccountAddress,
    sequence_number: u64,
    client: &mut LibraClient) -> Result<TransactionView, Error>{
        let mut max_iterations = 10;
        println!(
            "Waiting for tx from acc: {} with sequence number: {}",
            sender_address, sequence_number
        );

        loop {
            // prevent all Executing Result:the logging the client does while it loops through the query.
            stdout().flush().unwrap();

            // TODO: the `sequence_number - 1` makes it not possible to query the first sequence number of an account. However all 0L accounts are initiated by submitted a mining proof. So we need to be able to produce user feedback on the submission of their first block.

            let seq = if sequence_number > 0 {
                sequence_number - 1
            } else {
                0
            }; 
            
            match &mut client
                .get_txn_by_acc_seq(sender_address, seq, true){
                Ok(Some(txn_view)) => {
                return Ok(txn_view.to_owned());
            },
                Err(e) => {
                    println!("Response with error: {:?}", e);
                }
                _ => {
                    print!(".");
                }
            }
            max_iterations -= 1;
        //     if max_iterations == 0 {
        //         panic!("wait_for_transaction timeout");
        //     }
            thread::sleep(time::Duration::from_millis(100));
    }
}


pub fn eval_tx_status (result: Result<Option<TransactionView>, Error>) -> bool {
    match result {
        Ok(tx_view) => {
            // We receive a tx object.
            match tx_view {
                Some(tx_view) => {
                    if tx_view.vm_status != StatusCode::EXECUTED {
                        println!("Not executed");
                        return false
                    } else {
                        println!("Executed");
                        return true
                    }
                }
                //did not receive tx_object but it wasn't in error. This is likely because it's the first sequence number and we are skipping.
                None => { 
                    println!("No tx_view returned");
                    return false
                }
            }

        },
        // A tx_view was not returned because of timeout or client connection not established, or other unrelated to vm execution.
        Err(e) => {
            println!("Transaction err: {:?}", e);
            return false
        }

    }
}
