//! MinerApp submit_tx module
#![forbid(unsafe_code)]
use libra_global_constants::OPERATOR_KEY;
use libra_secure_storage::{NamespacedStorage, OnDiskStorageInternal, Storage};
use libra_types::{waypoint::Waypoint};
use libra_secure_storage::CryptoStorage;
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

use libra_types::transaction::{Script, TransactionPayload};
use libra_types::{transaction::helpers::*};
use crate::config::MinerConfig;
// use compiled_stdlib::transaction_scripts;
use libra_json_rpc_types::views::{TransactionView, VMStatusView};
use libra_types::chain_id::ChainId;
use libra_genesis_tool::keyscheme::KeyScheme;

/// All the parameters needed for a client transaction.
#[derive(Debug)]
pub struct TxParams {
    /// Sender's 0L authkey, may be the operator.
    pub sender_auth_key: AuthenticationKey,
    /// User's operator sender account if different than the owner account, used to send transactions
    pub sender_address: AccountAddress,
    /// User's 0L owner address, where the mining proofs go to.
    pub owner_address: AccountAddress,
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
    is_operator: bool,
) -> Result<TransactionView, Error> {

    // Create a client object
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let chain_id = ChainId::new(client.get_metadata().unwrap().chain_id);

    // For sequence number
    let (account_state,_) = client.get_account(tx_params.sender_address.clone(), true).unwrap();
    let sequence_number = match account_state {
        Some(av) => av.sequence_number,
        None => 0,
    };

    let script: Script = if is_operator {
        transaction_builder::encode_minerstate_commit_by_operator_script(tx_params.owner_address.clone(), preimage, proof)
    } else {
        // if owner sending with mnemonic
        transaction_builder::encode_minerstate_commit_script(preimage, proof)
    };

    // sign the transaction script
    let txn = create_user_txn(
        &tx_params.keypair,
        TransactionPayload::Script(script),
        tx_params.sender_address,
        sequence_number,
        tx_params.max_gas_unit_for_tx,
        tx_params.coin_price_per_unit,
        "GAS".parse()?,
        tx_params.user_tx_timeout as i64, // for compatibility with UTC's timestamp.
        chain_id,
    )?;

    // get account_data struct
    let mut sender_account_data = AccountData {
        address: tx_params.sender_address,
        authentication_key: Some(tx_params.sender_auth_key.to_vec()),
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
            match wait_for_tx(tx_params.sender_address, sequence_number, &mut client) {
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
    op_validator_network_addresses: Vec<u8>,
    op_fullnode_network_addresses: Vec<u8>,
    op_human_name: Vec<u8>,
) -> Result<TransactionView, Error> {

    // Create a client object
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let chain_id = ChainId::new(client.get_metadata().unwrap().chain_id);

    let (account_state,_) = client.get_account(tx_params.owner_address.clone(), true).unwrap();
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
        op_validator_network_addresses,
        op_fullnode_network_addresses,
        op_human_name,
        // vec!(),
        // vec!(),
    );

    // sign the transaction script
    let txn = create_user_txn(
        &tx_params.keypair,
        TransactionPayload::Script(script),
        tx_params.sender_address,
        sequence_number,
        tx_params.max_gas_unit_for_tx,
        tx_params.coin_price_per_unit,
        "GAS".parse()?,
        tx_params.user_tx_timeout as i64, // for compatibility with UTC's timestamp.
        chain_id,
    )?;

    // get account_data struct
    let mut sender_account_data = AccountData {
        address: tx_params.sender_address,
        authentication_key: Some(tx_params.sender_auth_key.to_vec()),
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
            match wait_for_tx(tx_params.owner_address, sequence_number, &mut client) {
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

/// Form tx parameters struct, all info needed for client tx.
pub fn get_params(
    keys: KeyScheme, 
    waypoint: Waypoint,
    config: &MinerConfig,
    // url_opt overrides all node configs, takes precedence over use_backup_url
    url_opt: Option<Url>,
    backup_url: bool
) -> TxParams {
    // let keys = KeyScheme::new_from_mnemonic(mnemonic.to_string());
    let keypair = KeyPair::from(keys.child_0_owner.get_private_key());
    let pubkey =  &keypair.public_key;// keys.child_0_owner.get_public();
    let sender_auth_key = AuthenticationKey::ed25519(pubkey);
    let sender_address = sender_auth_key.derived_address();

    let url: Url = if url_opt.is_some() { 
        url_opt.expect("could nod parse url")
    } else {
        if backup_url {
            config.profile.upstream_nodes
            .clone()
            .unwrap()
            .into_iter()
            .next()
            .expect("no backup url provided in config toml")

        } else {
            config.profile.default_node.clone().expect("no url provided in config toml")
        }
    };

    TxParams {
        sender_auth_key,
        sender_address,
        owner_address: sender_address,
        url,
        waypoint,
        keypair,
        max_gas_unit_for_tx: 5_000,
        coin_price_per_unit: 1, // in micro_gas
        user_tx_timeout: 5_000,
    }
}


/// Form tx parameters struct 
pub fn get_oper_params(
    waypoint: Waypoint,
    config: &MinerConfig,
    // url_opt overrides all node configs, takes precedence over use_backup_url
    url_opt: Option<Url>,
    backup_url: bool
) -> TxParams {
    let orig_storage = Storage::OnDiskStorage(OnDiskStorageInternal::new(config.workspace.node_home.join("key_store.json").to_owned()));
    let storage = Storage::NamespacedStorage(
        NamespacedStorage::new(
            orig_storage, 
            format!("{}-oper", &config.profile.auth_key )
        )
    );
    // export_private_key_for_version
    let privkey = storage.export_private_key(OPERATOR_KEY).expect("could not parse operator key in key_store.json");
    
    let keypair = KeyPair::from(privkey);
    let pubkey =  &keypair.public_key;// keys.child_0_owner.get_public();
    let auth_key = AuthenticationKey::ed25519(pubkey);
    
    let url: Url = if url_opt.is_some() { 
        url_opt.expect("could nod parse url")
    } else {
        if backup_url {
            config.profile.upstream_nodes
            .clone()
            .unwrap()
            .into_iter()
            .next()
            .expect("no backup url provided in config toml")

        } else {
            config.profile.default_node.clone().expect("no url provided in config toml")
        }
    };

    TxParams {
        sender_auth_key: auth_key,
        sender_address: auth_key.derived_address(),
        owner_address: config.profile.account, // address of sender
        url,
        waypoint,
        keypair,
        max_gas_unit_for_tx: 5_000,
        coin_price_per_unit: 1, // in micro_gas
        user_tx_timeout: 5_000,
    }
}


/// Submit a miner transaction to the network.
pub fn util_save_tx(
    tx_params: &TxParams,
){

    // Create a client object
    // let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let chain_id = ChainId::new(1);

    // let (account_state,_) = client.get_account(tx_params.address.clone(), true).unwrap();
    // let sequence_number = match account_state {
    //     Some(av) => av.sequence_number,
    //     None => 0,
    // };

    let script = transaction_builder::encode_demo_e2e_script(42);

    // TODO, how does Alice get Bob's tx sequence number?
    // sign the transaction script
    let txn = create_user_txn(
        &tx_params.keypair,
        TransactionPayload::Script(script),
        tx_params.sender_address,
        1,
        tx_params.max_gas_unit_for_tx,
        tx_params.coin_price_per_unit,
        "GAS".parse().unwrap(),
        tx_params.user_tx_timeout as i64, // for compatibility with UTC's timestamp.
        chain_id,
    );

    match txn {
        Ok(signed_tx) => {
            println!("Signed tx: {:?}", signed_tx);
        }
        Err(e) => {
            println!("Could not write tx: {:?}", e);
        }
    }

    // // get account_data struct
    // let mut sender_account_data = AccountData {
    //     address: tx_params.address,
    //     authentication_key: Some(tx_params.auth_key.to_vec()),
    //     key_pair: Some(tx_params.keypair.clone()),
    //     sequence_number,
    //     status: AccountStatus::Persisted,
    // };
    
    // // Submit the transaction with libra_client
    // match client.submit_transaction(
    //     Some(&mut sender_account_data),
    //     txn
    // ){
    //     Ok(_) => {
    //         match wait_for_tx(tx_params.address, sequence_number, &mut client) {
    //             Some(res) => Ok(res),
    //             None => Err(Error::msg("No Transaction View returned"))
    //         }
    //     }
    //     Err(err) => Err(err)
    // }

}


#[test]
fn test_make_params() {
    use libra_types::PeerId; 
    use crate::config::MinerConfig::{
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
            default_node: Some("http://localhost:8080".parse().unwrap()),
            upstream_nodes: None,
        },

    };

    let keys = KeyScheme::new_from_mnemonic(mnemonic.to_owned());
    let p = get_params(keys, waypoint, &configs_fixture, None, false);
    assert_eq!("http://localhost:8080/".to_string(), p.url.to_string());
    // debug!("{:?}", p.url);
    //make_params
}

#[test]
fn test_save_tx() {
    use libra_types::PeerId; 
    use ol_cli::config::{
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
            default_node: Some("http://localhost:8080".parse().unwrap()),
            upstream_nodes: None,
        },

    };
    let keys = KeyScheme::new_from_mnemonic(mnemonic.to_owned());
    let p = get_params(keys, waypoint, &configs_fixture, None, false);
    util_save_tx(&p);
}