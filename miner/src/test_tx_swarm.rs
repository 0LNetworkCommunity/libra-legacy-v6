//! MinerApp submit_tx module
#![forbid(unsafe_code)]

use crate::{backlog, block::ValConfigs};
use crate::block::build_block::{mine_genesis, mine_once, parse_block_height};
use crate::config::MinerConfig;
use crate::prelude::*;
use crate::submit_tx::{ submit_tx, TxParams, eval_tx_status};
use crate::node_keys;
use anyhow::Error;
use libra_config::config::{self, NodeConfig, OnDiskStorageConfig};
use libra_crypto::test_utils::KeyPair;
use libra_types::waypoint::Waypoint;
use libra_types::transaction::authenticator::AuthenticationKey;
use reqwest::Url;
use std::{fs, path::PathBuf};

/// A test harness for the submit_tx with a local swarm 
pub fn test_runner(home: PathBuf) {

    let tx_params = get_params_from_swarm(home).unwrap();
    let conf = MinerConfig::load_swarm_config(&tx_params);
    // TODO: count three blocks and exit
    // let i = 0;
    // while i < 4 {
    //     let (preimage, proof) = get_block_fixtures(&conf);

    //     // need to sleep for swarm to be ready.
    //     thread::sleep(time::Duration::from_millis(50000));
    //     let res = submit_tx(&tx_params, preimage, proof, false);
    //     if eval_tx_status(res) == false {
    //         std::process::exit(0);
    //     };
    //     i+1;
    // }
    backlog::process_backlog(&conf, &tx_params);

    loop {
        let (preimage, proof) = get_block_fixtures(&conf);
        // need to sleep for swarm to be ready.

        match submit_tx(&tx_params, preimage, proof, false) {
            Err(err)=>{ println!("{:?}", err) }
            res =>{
                if eval_tx_status(res) == false {
                    break;
                };

            }
        }
    }
}

/// A test harness for the submit_tx with a local swarm 
pub fn val_init_test(home: PathBuf) {
    let file = "./blocks/val_init.json";
    fs::copy("../fixtures/val_init.json", file).unwrap();
    let block_file = fs::read_to_string(file)
        .expect("Could not read init file");

    let init_file: ValConfigs =
        serde_json::from_str(&block_file).expect("could not deserialize latest block");
    dbg!(&init_file);

    let tx_params = get_params_from_swarm(home).unwrap();
    // let conf = MinerConfig::load_swarm_config(&tx_params);
    // // TODO: count three blocks and exit
    // // let i = 0;
    // // while i < 4 {
    // //     let (preimage, proof) = get_block_fixtures(&conf);

    // //     // need to sleep for swarm to be ready.
    // //     thread::sleep(time::Duration::from_millis(50000));
    // //     let res = submit_tx(&tx_params, preimage, proof, false);
    // //     if eval_tx_status(res) == false {
    // //         std::process::exit(0);
    // //     };
    // //     i+1;
    // // }
    // backlog::process_backlog(&conf, &tx_params);

    // loop {
        // let (preimage, proof) = get_block_fixtures(&conf);
        // need to sleep for swarm to be ready.

        match submit_tx(&tx_params, init_file.block_zero.preimage, init_file.block_zero.proof, true) {
            Err(err)=>{ println!("{:?}", err) }
            Ok(res) => {dbg!(Some(res));}
        }
    // }
}


fn get_block_fixtures (config: &MinerConfig) -> (Vec<u8>, Vec<u8>){

    // get the location of this miner's blocks
    let mut blocks_dir = config.workspace.miner_home.clone();
    blocks_dir.push(&config.chain_info.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);

    // If there are NO files in path, mine the genesis proof.
    if current_block_number.is_none() {
        status_info!("[swarm] Generating Genesis Proof", "0");
        mine_genesis(&config);
        status_ok!("[swarm] Success", "Genesis block_0.json created, exiting.");
        std::process::exit(0);
    }

    // mine continuously from the last block in the file systems
    let mining_height = current_block_number.unwrap() + 1;
    status_info!("[swarm] Generating Proof for block:", format!("{}", mining_height));
    let block = mine_once(&config).unwrap();
    status_ok!("[swarm] Success", format!("block_{}.json created.", block.height.to_string()));
    (block.preimage, block.proof)
}

fn get_params_from_swarm (mut home: PathBuf) -> Result<TxParams, Error> {
    home.push("0/node.yaml");
    if !home.exists() {
        home = PathBuf::from("/root/saved_logs/0/node.yaml")
    }
    let config = NodeConfig::load(&home)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &home));
    match &config.test {
        Some(_conf) => {
            // println!("Swarm Keys : {:?}", conf);
        },
        None =>{
            println!("test config does not set.");
        }
    }
    
    // let test_config = config.test.unwrap();
    // let private_key = test_config.operator_key.unwrap();

    // This mnemonic is hard coded into the swarm configs. see configs/config_builder
    let alice_mnemonic = "average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice".to_string();
    let private_key = node_keys::key_scheme_new(alice_mnemonic);
    let keypair = KeyPair::from(private_key.child_0_owner.get_private_key());

    let auth_key = AuthenticationKey::ed25519(&private_key.child_0_owner.get_public());
    let address = auth_key.derived_address();

    let url =  Url::parse(format!("http://localhost:{}", config.json_rpc.address.port()).as_str()).unwrap();

    dbg!(&config.base);
    // let mut storage_cfg = OnDiskStorageConfig::default();
    // storage_cfg.set_data_dir(PathBuf::from("/root/saved_logs/".to_string()));
    // storage_cfg.path = PathBuf::from("/root/saved_logs/full_node_0_operator".to_string());
    // storage_cfg.namespace = Some("0_owner".to_string());
    // {
    //     namespace: Some("0_owner".to_string()),
    //     path: PathBuf::from("/root/saved_logs/full_node_0_operator"),
    //     // data_dir: PathBuf::from("/root/saved_logs/"),
    // };
    // let validator_storage = config::Storage::OnDiskStorage(storage_cfg);
    // let wrapper = config::Storage::StorageWrapper {
    //     storage_name: "validator",
    //     storage: validator_storage,
    // };
    // dbg!(&wrapper.value("waypoint"));
    // let parsed_waypoint: Waypoint = config.base.waypoint.waypoint_from_config().unwrap().clone();
    let parsed_waypoint = config.base.waypoint.genesis_waypoint();

    
    let tx_params = TxParams {
        auth_key,
        address,
        url,
        waypoint: parsed_waypoint,
        keypair,
        max_gas_unit_for_tx: 1_000_000,
        coin_price_per_unit: 0,
        user_tx_timeout: 5_000,
    };

    Ok(tx_params)
}