//! Txs App submit_tx module
#![forbid(unsafe_code)]

use anyhow::Error;
use abscissa_core::{Command, status_warn, status_ok};
use cli::{libra_client::LibraClient, AccountData, AccountStatus};
use crate::{config::AppConfig, commands, entrypoint::EntryPoint};
use libra_crypto::{
    test_utils::KeyPair,
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey}
};
use libra_config::config::NodeConfig;
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
use std::{fs, io::{stdout, Write}, path::{Path, PathBuf}, thread, time};

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

/// Submit a transaction to the network.
pub fn submit_tx(
    tx_params: &TxParams,
    script: Script,
) -> Result<TransactionView, Error> {
    let mut client = LibraClient::new(
        tx_params.url.clone(), tx_params.waypoint
    ).unwrap();

    let chain_id = ChainId::new(client.get_metadata().unwrap().chain_id);
    let (account_state,_) = client.get_account(
        tx_params.address.clone(), true
    ).unwrap();

    let sequence_number = match account_state {
        Some(av) => av.sequence_number,
        None => 0,
    };

    // Sign the transaction script
    let txn = create_user_txn(
        &tx_params.keypair,
        TransactionPayload::Script(script),
        tx_params.address,
        sequence_number,
        tx_params.max_gas_unit_for_tx,
        tx_params.coin_price_per_unit,
        "GAS".parse()?,
        // for compatibility with UTC's timestamp
        tx_params.user_tx_timeout as i64, 
        chain_id,
    )?;

    // Get account_data struct
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
            match wait_for_tx(
                tx_params.address, sequence_number, &mut client
            ) {
                Some(res) => Ok(res),
                None => Err(Error::msg("No Transaction View returned"))
            }
        }
        Err(err) => Err(err)
    }

}

/// Main get tx params logic based on the design in this URL:
/// https://github.com/OLSF/libra/wiki/Txs-App#txs-logic--usage
pub fn get_tx_params() -> Result<TxParams, Error> {
    type EntryPointTxsCmd = EntryPoint<commands::TxsCmd>;
    let EntryPointTxsCmd { 
        url, waypoint, swarm_path, .. } = Command::from_env_args();

    let mut tx_params: TxParams;
    let txs_config = crate::prelude::app_config();

    if swarm_path.is_some() {
        tx_params = get_tx_params_from_swarm(
            swarm_path.clone().expect("needs a valid swarm temp dir")
        ).unwrap();
    } else {
        // Get from txs.toml e.g. ~/.0L/txs.toml, or use Profile::default()
        tx_params = get_tx_params_from_toml(txs_config.clone()).unwrap();        
    }

    // Get/override dynamic waypoint from key_store.json
    if Path::new(&txs_config.get_key_store_path()).exists() {
        tx_params.waypoint = txs_config.get_waypoint().unwrap();
    }

    // Get/override some params from command line
    if url.is_some() {
        tx_params.url = Url::parse(&url.unwrap()).unwrap();
    }
    if waypoint.is_some() {
        tx_params.waypoint = waypoint.unwrap().parse().unwrap();
    }

    Ok(tx_params)
}

/// Extract params from a local running swarm
pub fn get_tx_params_from_swarm(
    mut swarm_path: PathBuf
) 
-> Result<TxParams, Error> {
    swarm_path.push("0/node.yaml");
    let config = NodeConfig::load(&swarm_path).unwrap_or_else(
        |_| panic!("Failed to load NodeConfig from file: {:?}", &swarm_path)
    );
    let url =  Url::parse(
        format!("http://localhost:{}", config.json_rpc.address.port()).as_str()
    ).unwrap();
    let waypoint = config.base.waypoint.genesis_waypoint();

    let alice_mnemonic = fs::read_to_string("./fixtures/mnemonic/alice.mnem")
        .expect("Unable to read file");
    let keys = KeyScheme::new_from_mnemonic(alice_mnemonic);
    let keypair = KeyPair::from(keys.child_0_owner.get_private_key());
    let pubkey =  keys.child_0_owner.get_public();
    let auth_key = AuthenticationKey::ed25519(&pubkey);
    let address = auth_key.derived_address();  

    let tx_params = TxParams {
        auth_key,
        address,
        url,
        waypoint,
        keypair,
        max_gas_unit_for_tx: 1_000_000,
        coin_price_per_unit: 1, // in micro_gas
        user_tx_timeout: 5_000,
    };

    println!("Info: Got tx params from swarm");
    Ok(tx_params)
}

/// Gets transaction params from the 0L project root.
pub fn get_tx_params_from_toml(config: AppConfig) -> Result<TxParams, Error> {    
    let url =  Url::parse(&config.profile.url).unwrap();

    let (auth_key, address, wallet) = keygen::account_from_prompt();
    let keys = KeyScheme::new_from_mnemonic(wallet.mnemonic());
    let keypair = KeyPair::from(keys.child_0_owner.get_private_key());

    let tx_params = TxParams {
        auth_key,
        address,
        url,
        waypoint: config.profile.waypoint,
        keypair,
        max_gas_unit_for_tx: config.profile.max_gas_unit_for_tx,
        coin_price_per_unit: config.profile.coin_price_per_unit, // in micro_gas
        user_tx_timeout: config.profile.user_tx_timeout,
    };

    println!("Info: Getting tx params from txs.toml if available, \
              otherwise using AppConfig::Profile::default()");
    Ok(tx_params)
}

/// Wait for the response from the libra RPC.
pub fn wait_for_tx(
    sender_address: AccountAddress,
    sequence_number: u64,
    client: &mut LibraClient
) -> Option<TransactionView> {
        println!(
            "Awaiting tx status \n\
             Submitted from account: {} with sequence number: {}",
            sender_address, sequence_number
        );

        loop {
            thread::sleep(time::Duration::from_millis(1000));
            // prevent all the logging the client does while 
            // it loops through the query.
            stdout().flush().unwrap();
            
            match &mut client.get_txn_by_acc_seq(
                sender_address, sequence_number, false
            ){
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

/// Evaluate the response of a submitted txs transaction.
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

// #[test]
// fn test_make_params() {
//     use libra_types::PeerId; 
//     use crate::config::{
//         Workspace,
//         Profile,
//     };
//     use std::path::PathBuf;

//     let mnemonic = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse";
//     let waypoint: Waypoint =  "0:3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2".parse().unwrap();
//     let configs_fixture = AppConfig {
//         workspace: Workspace{
//             node_home: PathBuf::from("."),
//         },
//         profile: Profile {
//             auth_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
//                 .to_owned(),
//             account: PeerId::from_hex_literal("0x000000000000000000000000deadbeef").unwrap(),
//             ip: "1.1.1.1".parse().unwrap(),
//             statement: "Protests rage across the nation".to_owned(),
//         },

//     };

//     let keys = KeyScheme::new_from_mnemonic(mnemonic.to_owned());
//     let p = get_params(keys, waypoint, &configs_fixture);
//     assert_eq!("http://localhost:8080/".to_string(), p.url.to_string());
//     // debug!("{:?}", p.url);
//     //make_params
// }