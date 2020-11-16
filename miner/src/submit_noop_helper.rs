use crate::node_keys;
use libra_wallet::{Mnemonic, key_factory::{
    Seed, KeyFactory, ChildNumber
}};
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
use crate::{
    config::MinerConfig
};
use compiled_stdlib::transaction_scripts;
use libra_json_rpc_types::views::{TransactionView, VMStatusView};
use libra_types::chain_id::ChainId;

fn submit_noop() -> Result<String, Error> {
    let path = PathBuf::from("/root/saved_logs/0/node.yaml");
    let config = NodeConfig::load(&path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &home));
    match &config.test {
        Some(_conf) => {
            // println!("Swarm Keys : {:?}", conf);
        },
        None =>{
            println!("test config does not set.");
        }
    }

    // This mnemonic is hard coded into the swarm configs. see configs/config_builder
    let alice_mnemonic = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse".to_string();
    let private_key = node_keys::key_scheme_new(alice_mnemonic);
    let keypair = KeyPair::from(private_key.child_0_owner.get_private_key());

    let auth_key = AuthenticationKey::ed25519(&private_key.child_0_owner.get_public());
    let address = auth_key.derived_address();


    // config_path.push("../saved_logs/0/node.config.toml");

    // let config = NodeConfig::load(&config_path)
    //     .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", config_path));
    // match &config.test {
    //     Some( conf) => {
    //         // println!("Swarm Keys : {:?}", conf);
    //     },
    //     None =>{
    //         // println!("test config does not set.");
    //     }
    // }

    // // Create a client object
    // let mut client = LibraClient::new(
    //     Url::parse(format!("http://localhost:{}", config.rpc.address.port()).as_str()).unwrap(),
    //     config.base.waypoint.waypoint_from_config().unwrap().clone()
    // ).unwrap();

    
    // let mut private_key = config.test.unwrap().operator_keypair.unwrap();
    
    // let auth_key = AuthenticationKey::ed25519(&private_key.public_key());
    // let address = auth_key.derived_address();


    let account_state = client.get_account_state(address.clone(), true).unwrap();


    let mut sequence_number = 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }

    // Doing a no-op transaction here which will print
    // [debug] 000000000000000011e110  in the logs if successful.
    let hello_world= 100u64;
    let script = transaction_builder::encode_demo_e2e_script(hello_world);

    let keypair = KeyPair::from(private_key.take_private().clone().unwrap());
    
    let chain_id = ChainId::new(1);

    let txn = create_user_txn(
        &keypair,
        TransactionPayload::Script(script),
        address,
        sequence_number,
        700_000,
        0,
        "GAS".parse()?,
        5_000_000,
        chain_id
    )?;

    // get account_data struct
    let mut sender_account_data = AccountData {
        address,
        authentication_key: Some(auth_key.to_vec()),
        key_pair: Some(keypair),
        sequence_number,
        status: AccountStatus::Persisted,
    };


    // Submit the transaction with libra_client
    match client.submit_transaction(
        Some(&mut sender_account_data),
        txn
    ){
        Ok(_) => {
            ol_wait_for_tx(address, sequence_number, &mut client);
            Ok("Tx submitted".to_string())

        }
        Err(err) => Err(err)
    }
}
