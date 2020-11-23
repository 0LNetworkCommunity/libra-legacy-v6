//! MinerApp submit_tx module
#![forbid(unsafe_code)]

use crate::{node_keys::KeyScheme, backlog, block::ValConfigs};
use crate::block::build_block::{mine_genesis, mine_once, parse_block_height};
use crate::config::MinerConfig;
use crate::prelude::*;
use crate::submit_tx::{ submit_tx, TxParams, eval_tx_status};
use anyhow::Error;
use libra_config::config::NodeConfig;
use libra_crypto::test_utils::KeyPair;
use libra_types::transaction::authenticator::AuthenticationKey;
use reqwest::Url;
use std::{fs, path::PathBuf};

/// A test harness for the submit_tx with a local swarm 
pub fn swarm_miner(swarm_path: PathBuf) {

    let tx_params = get_params_from_swarm(swarm_path).unwrap();
    let conf = MinerConfig::load_swarm_config(&tx_params);
    fs::create_dir_all("./swarm_temp/blocks").unwrap();
    fs::copy("./fixtures/test/alice/block_0.json", "./swarm_temp/blocks/block_0.json").expect("error copying file");

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
pub fn swarm_onboarding(swarm_path: PathBuf) {
    // let file = "./blocks/val_init.json";
    // fs::copy("../fixtures/val_init_stage.json", file).unwrap();
    let init_file = fs::read_to_string("./fixtures/val_init_stage.json")
        .expect("Could not read init file");

    let init_file: ValConfigs =
        serde_json::from_str(&init_file).expect("could not deserialize val_init.json");

    let tx_params = get_params_from_swarm(swarm_path).unwrap();
        match submit_tx(&tx_params, init_file.block_zero.preimage, init_file.block_zero.proof, true) {
            Err(err)=>{ println!("{:?}", err) }
            Ok(res) => {println!("{:?}",Some(res));}
        }
}


fn get_block_fixtures (config: &MinerConfig) -> (Vec<u8>, Vec<u8>){

    // get the location of this miner's blocks
    let mut blocks_dir = config.workspace.node_home.clone();
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

fn get_params_from_swarm(mut swarm_path: PathBuf) -> Result<TxParams, Error> {
    swarm_path.push("0/node.yaml");
    let config = NodeConfig::load(&swarm_path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &swarm_path));

    // This mnemonic is hard coded into the swarm configs. see configs/config_builder
    let alice_mnemonic = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse".to_string();
    let keys = KeyScheme::new_from_mnemonic(alice_mnemonic);
    let keypair = KeyPair::from(keys.child_0_owner.get_private_key());
    let pubkey =  keys.child_0_owner.get_public();
    let auth_key = AuthenticationKey::ed25519(&pubkey);
    let address = auth_key.derived_address();

    let url =  Url::parse(format!("http://localhost:{}", config.json_rpc.address.port()).as_str()).unwrap();
    let waypoint = config.base.waypoint.genesis_waypoint();

    let tx_params = TxParams {
        auth_key,
        address,
        url,
        waypoint,
        keypair,
        max_gas_unit_for_tx: 5_000,
        coin_price_per_unit: 1, // in micro_gas
        user_tx_timeout: 5_000,
    };

    Ok(tx_params)
}