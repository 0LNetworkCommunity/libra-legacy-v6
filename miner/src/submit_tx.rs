//! MinerApp submit_tx module
#![forbid(unsafe_code)]
use libra_types::{waypoint::Waypoint};

use libra_types::{account_address::AccountAddress, transaction::authenticator::AuthenticationKey};
use libra_crypto::{
    test_utils::KeyPair,
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey}
};
use anyhow::Error;
use cli::{libra_client::LibraClient, AccountData, AccountStatus};
use reqwest::Url;
use abscissa_core::{status_warn, status_ok};
use std::{io::{stdout, Write}, thread, time};

use libra_types::transaction::{Script, TransactionArgument, TransactionPayload};
use libra_types::{transaction::helpers::*};
use crate::{node_keys::KeyScheme, config::MinerConfig};
use compiled_stdlib::transaction_scripts;
use libra_json_rpc_types::views::{TransactionView, VMStatusView};
use libra_types::chain_id::ChainId;

/// All the parameters needed for a client transaction.
pub struct TxParams {
    /// User's 0L authkey used in mining.
    pub auth_key: AuthenticationKey,
    /// User's 0L account used in mining
    pub address: AccountAddress,
    /// Url
    pub url: Url,
    /// waypoint
    pub waypoint: Waypoint,
    /// KeyPair
    pub keypair: KeyPair<Ed25519PrivateKey, Ed25519PublicKey>,
    /// User's Maximum gas_units willing to run. Different than coin. 
    pub max_gas_unit_for_tx: u64,
    /// User's GAS Coin price to submit transaction.
    pub coin_price_per_unit: u64,
    /// User's transaction timeout.
    pub user_tx_timeout: u64, // for compatibility with UTC's timestamp.
}

/// Submit a miner transaction to the network.
pub fn submit_tx(
    tx_params: &TxParams,
    preimage: Vec<u8>,
    proof: Vec<u8>,
    is_onboading: bool,
) -> Result<TransactionView, Error> {

    // Create a client object
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let chain_id = ChainId::new(client.get_metadata().unwrap().chain_id);

    let (account_state,_) = client.get_account(tx_params.address.clone(), true).unwrap();
    let sequence_number = match account_state {
        Some(av) => av.sequence_number,
        None => 0,
    };

    let script: Script;
    // Create the unsigned MinerState transaction script
    if !is_onboading {
        script = Script::new(
            transaction_scripts::StdlibScript::MinerStateCommit.compiled_bytes().into_vec(),
            vec![],
            vec![
                TransactionArgument::U8Vector(preimage),
                TransactionArgument::U8Vector(proof),
            ],
        );
    } else {

        let consensus_pubkey = hex::decode("8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010").unwrap();
        let validator_network_address = "test".as_bytes().to_vec();
        let full_node_network_address = "test".as_bytes().to_vec();
        let human_name = "test".as_bytes().to_vec();
        script = Script::new(
            transaction_scripts::StdlibScript::MinerStateOnboarding.compiled_bytes().into_vec(),
            vec![],
            vec![
                TransactionArgument::U8Vector(preimage), // challenge: vector<u8>,
                TransactionArgument::U8Vector(proof), // solution: vector<u8>,
                TransactionArgument::U8Vector(consensus_pubkey), // consensus_pubkey: vector<u8>,
                TransactionArgument::U8Vector(validator_network_address),// validator_network_address: vector<u8>,
                TransactionArgument::U8Vector(full_node_network_address),// full_node_network_address: vector<u8>,
                TransactionArgument::U8Vector(human_name),// human_name: vector<u8>,
            ],
        );
    }

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
        chain_id,
    )?;

    // get account_data struct
    let mut sender_account_data = AccountData {
        address: tx_params.address,
        authentication_key: Some(tx_params.auth_key.to_vec()),
        key_pair: Some(tx_params.keypair.clone()),
        sequence_number,
        status: AccountStatus::Persisted,
    };
    
    // Submit the transaction with libra_client
    match client.submit_transaction(
        Some(&mut sender_account_data),
        txn
    ){
        Ok(_) => {
            match wait_for_tx(tx_params.address, sequence_number, &mut client) {
                Some(res) => Ok(res),
                None => Err(Error::msg("No Transaction View returned"))
            }
        }
        Err(err) => Err(err)
    }

}


/// Submit a miner transaction to the network.
pub fn submit_onboard_tx(
    tx_params: &TxParams,
    preimage: Vec<u8>,
    proof: Vec<u8>,
    ow_human_name: Vec<u8>,
    op_address: AccountAddress,
    op_auth_key_prefix: Vec<u8>,
    op_consensus_pubkey: Vec<u8>,
    op_validator_network_addresses: String,
    op_fullnode_network_addresses: String,
    op_human_name: Vec<u8>,
) -> Result<TransactionView, Error> {

    // Create a client object
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let chain_id = ChainId::new(client.get_metadata().unwrap().chain_id);

    let (account_state,_) = client.get_account(tx_params.address.clone(), true).unwrap();
    let sequence_number = match account_state {
        Some(av) => av.sequence_number,
        None => 0,
    };

    let script = transaction_builder::encode_minerstate_onboarding_script(
        preimage,
        proof,
        ow_human_name,
        op_address,
        op_auth_key_prefix,
        op_consensus_pubkey,
        op_validator_network_addresses.as_bytes().to_vec(),
        op_fullnode_network_addresses.as_bytes().to_vec(),
        op_human_name,
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
        chain_id,
    )?;

    // get account_data struct
    let mut sender_account_data = AccountData {
        address: tx_params.address,
        authentication_key: Some(tx_params.auth_key.to_vec()),
        key_pair: Some(tx_params.keypair.clone()),
        sequence_number,
        status: AccountStatus::Persisted,
    };
    
    // Submit the transaction with libra_client
    match client.submit_transaction(
        Some(&mut sender_account_data),
        txn
    ){
        Ok(_) => {
            match wait_for_tx(tx_params.address, sequence_number, &mut client) {
                Some(res) => Ok(res),
                None => Err(Error::msg("No Transaction View returned"))
            }
        }
        Err(err) => Err(err)
    }

}


/// Wait for the response from the libra RPC.
pub fn wait_for_tx(
    sender_address: AccountAddress,
    sequence_number: u64,
    client: &mut LibraClient) -> Option<TransactionView>{
        println!(
            "Awaiting tx status \nSubmitted from account: {} with sequence number: {}",
            sender_address, sequence_number
        );

        loop {
            thread::sleep(time::Duration::from_millis(1000));
            // prevent all the logging the client does while it loops through the query.
            stdout().flush().unwrap();
            
            match &mut client.get_txn_by_acc_seq(sender_address, sequence_number, false){
                Ok(Some(txn_view)) => {
                    return Some(txn_view.to_owned());
                },
                Err(e) => {
                    println!("Response with error: {:?}", e);
                },
                _ => {
                    print!(".");
                }
            }

        }
}

/// Evaluate the response of a submitted miner transaction.
pub fn eval_tx_status(result: TransactionView) -> bool {
    match result.vm_status == VMStatusView::Executed {
        true => {
                status_ok!("\nSuccess:", "transaction executed");
                return true
        }
        false => {
                status_warn!("Transaction failed");
                println!("Rejected with code:{:?}", result.vm_status);
                return false
        }, 
    }
}

/// Form tx parameters struct 
pub fn get_params(
    mnemonic: &str, 
    waypoint: Waypoint,
    config: &MinerConfig
) -> TxParams {
    let keys = KeyScheme::new_from_mnemonic(mnemonic.to_string());
    let keypair = KeyPair::from(keys.child_0_owner.get_private_key());
    let pubkey =  &keypair.public_key;// keys.child_0_owner.get_public();
    let auth_key = AuthenticationKey::ed25519(pubkey);
    let url_str = config.chain_info.node.as_ref().unwrap();

    TxParams {
        auth_key,
        address: config.profile.account,
        url: Url::parse(url_str).expect("No url provided in miner.toml"),
        waypoint,
        keypair,
        max_gas_unit_for_tx: 50_000,
        coin_price_per_unit: 1, // in micro_gas
        user_tx_timeout: 5_000,
    }
}

#[test]
fn test_make_params() {
    use libra_types::PeerId; 
    use crate::config::{
        Workspace,
        Profile,
        ChainInfo
    };
    use std::path::PathBuf;

    let mnemonic = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse";
    let waypoint: Waypoint =  "0:3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2".parse().unwrap();
    let configs_fixture = MinerConfig {
        workspace: Workspace{
            node_home: PathBuf::from("."),
        },
        profile: Profile {
            auth_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
                .to_owned(),
            account: PeerId::from_hex_literal("0x000000000000000000000000deadbeef").unwrap(),
            ip: "1.1.1.1".parse().unwrap(),
            statement: "Protests rage across the nation".to_owned(),
        },
        chain_info: ChainInfo {
            chain_id: "0L testnet".to_owned(),
            block_dir: "test_blocks_temp_2".to_owned(),
            base_waypoint: None,
            node: Some("http://localhost:8080".to_string()),
        },

    };

    let p = get_params(&mnemonic, waypoint, &configs_fixture);
    assert_eq!("http://localhost:8080/".to_string(), p.url.to_string());
    // debug!("{:?}", p.url);
    //make_params
}

#[test]
fn test_save_tx() {
    dbg!(&"test");

}