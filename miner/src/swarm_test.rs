//! OlMiner submit_tx module
#![forbid(unsafe_code)]

use crate::{backlog, block::build_block::{mine_genesis, mine_once, parse_block_height}};

use crate::config::OlMinerConfig;

use crate::prelude::*;
use crate::submit_tx::{
    submit_tx, TxParams, eval_tx_status};
use anyhow::Error;

use libra_config::config::NodeConfig;
use libra_crypto::{
    test_utils::KeyPair,
};


use libra_types::waypoint::Waypoint;
use libra_types::{transaction::authenticator::AuthenticationKey};

use reqwest::Url;
use std::{path::PathBuf, thread, time};


// use crate::application::{MINER_MNEMONIC, DEFAULT_PORT};
// const DEFAULT_PORT: u64 = 2344; // TODO: this will likely deprecated in favor of urls and discovery.
                                // const DEFAULT_NODE: &str = "src/config/test_data/single.node.config.toml";
/// A test harness for the submit_tx
pub fn test_runner(home: PathBuf, _parent_config: &OlMinerConfig, _no_submit: bool) {
    // PathBuf.new("./blocks")
    let tx_params = get_params_from_swarm(home).unwrap();
    let conf = OlMinerConfig::load_swarm_config(&tx_params);
    backlog::backlog(&conf, &tx_params);

    loop {
        let (preimage, proof) = get_block_fixtures(&conf);

        // need to sleep for swarm to be ready.
        thread::sleep(time::Duration::from_millis(24000));
        let res = submit_tx(&tx_params, preimage, proof, false);
        if eval_tx_status(res) == false {
            break;
        };
    }
}

fn get_block_fixtures (config: &OlMinerConfig) -> (Vec<u8>, Vec<u8>){

    // get the location of this miner's blocks
    let mut blocks_dir = config.workspace.home.clone();
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
    (block.preimage, block.data)
}

fn get_params_from_swarm (mut home: PathBuf) -> Result<TxParams, Error> {
    home.push("0/node.config.toml");
    if !home.exists() {
        home = PathBuf::from("../saved_logs/0/node.config.toml")
    }
    let config = NodeConfig::load(&home)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &home));
    match &config.test {
        Some( conf) => {
            println!("Swarm Keys : {:?}", conf);
        },
        None =>{
            println!("test config does not set.");
        }
    }
    
    let mut private_key = config.test.unwrap().operator_keypair.unwrap();
    let auth_key = AuthenticationKey::ed25519(&private_key.public_key());
    let address = auth_key.derived_address();

    let url =  Url::parse(format!("http://localhost:{}", config.rpc.address.port()).as_str()).unwrap();

    let parsed_waypoint: Waypoint = config.base.waypoint.waypoint_from_config().unwrap().clone();
    
    let keypair = KeyPair::from(private_key.take_private().clone().unwrap());
    dbg!(&keypair);
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
