//! MinerApp submit_tx module
#![forbid(unsafe_code)]

use crate::{backlog};
use crate::block::build_block::{mine_genesis, mine_once, parse_block_height};
use crate::config::MinerConfig;
use crate::prelude::*;
use crate::submit_tx::{ submit_tx, TxParams, eval_tx_status};
use anyhow::Error;
use libra_config::config::NodeConfig;
use libra_crypto::test_utils::KeyPair;
use libra_types::transaction::authenticator::AuthenticationKey;
use reqwest::Url;
use std::{fs, path::{Path, PathBuf}};
use libra_genesis_tool::keyscheme::KeyScheme;

/// A test harness for the submit_tx with a local swarm 
pub fn swarm_miner(swarm_path: PathBuf, persona: &Option<String>) {
    let persona = persona.clone().unwrap_or("alice".to_string());
    let tx_params = get_params_from_swarm(swarm_path, &persona).unwrap();
    let conf = load_swarm_config(&tx_params);
    let swarm_block_path = "./swarm_temp/blocks";
    if Path::new(swarm_block_path).exists() { fs::remove_dir_all(swarm_block_path).unwrap() };
    fs::create_dir_all("./swarm_temp/blocks").unwrap();
    let filepath = format!("./fixtures/blocks/test/{}/block_0.json", persona);
    fs::copy(filepath, "./swarm_temp/blocks/block_0.json").expect("error copying file");

    dbg!(&tx_params);

    backlog::process_backlog(&conf, &tx_params, false);

    loop {
        let (preimage, proof) = get_block_fixtures(&conf);
        // need to sleep for swarm to be ready.

        match submit_tx(&tx_params, preimage, proof, false) {
            Err(err)=>{ println!("{:?}", err) }
            Ok(res) =>{
                if !eval_tx_status(res){
                    break;
                };

            }
        }
    }
}

/// Get configs from a running swarm instance.
fn load_swarm_config(param: &TxParams) -> MinerConfig {
    let mut conf = MinerConfig::default();
    conf.workspace.node_home = PathBuf::from("./swarm_temp");
    // Load profile config
    conf.profile.account = param.owner_address;
    conf.profile.auth_key = param.sender_auth_key.to_string();

    // Load chain info
    conf.profile.default_node = Some(param.url.clone());
    conf
}

fn get_block_fixtures(config: &MinerConfig) -> (Vec<u8>, Vec<u8>){

    // get the location of this miner's blocks
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);

    // If there are NO files in path, mine the genesis proof.
    if current_block_number.is_none() {
        status_info!("[swarm] Generating Genesis Proof", "0");
        mine_genesis(&config);
        status_ok!("[swarm] Success", "Genesis block_0.json created. Exiting.");
        std::process::exit(0);
    }

    // mine continuously from the last block in the file systems
    let mining_height = current_block_number.unwrap() + 1;
    status_info!("[swarm] Generating Proof for block:", format!("{}", mining_height));
    let block = mine_once(&config).unwrap();
    status_ok!("[swarm] Success", format!("block_{}.json created.", block.height.to_string()));
    (block.preimage, block.proof)
}

/// Helper to extract params from a local running swarm.
pub fn get_params_from_swarm(mut swarm_path: PathBuf, persona: &str) -> Result<TxParams, Error> {
    swarm_path.push("0/node.yaml");
    let config = NodeConfig::load(&swarm_path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &swarm_path));

    // This mnemonic is hard coded into the swarm configs. see configs/config_builder
    let mnem_path = format!("./fixtures/mnemonic/{}.mnem", persona);
    let mnemonic = String::from_utf8(fs::read(mnem_path).unwrap()).unwrap();
    let keys = KeyScheme::new_from_mnemonic(mnemonic);
    let keypair = KeyPair::from(keys.child_0_owner.get_private_key());
    let pubkey =  keys.child_0_owner.get_public();
    let sender_auth_key = AuthenticationKey::ed25519(&pubkey);
    let sender_address = sender_auth_key.derived_address();

    let url =  Url::parse(format!("http://localhost:{}", config.json_rpc.address.port()).as_str()).unwrap();
    let waypoint = config.base.waypoint.genesis_waypoint();

    let tx_params = TxParams {
        sender_auth_key,
        sender_address,
        owner_address: sender_address,
        url,
        waypoint,
        keypair,
        max_gas_unit_for_tx: 5_000,
        coin_price_per_unit: 1, // in micro_gas
        user_tx_timeout: 5_000,
    };

    Ok(tx_params)
}