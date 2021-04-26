//! MinerApp resubmit_tx module
#![forbid(unsafe_code)]

use cli::{libra_client::LibraClient};
use std::fs::File;
use glob::glob;
use crate::{block::Block};
use std::io::BufReader;
use libra_json_rpc_types::views::MinerStateView;
use std::path::PathBuf;
//use crate::submit_tx::LocalMinerState;
use crate::config::MinerConfig;
use crate::submit_tx_alt::{TxParams, submit_tx, eval_tx_status};
use libra_config::config::NodeConfig;
use libra_types::{
    transaction::authenticator::AuthenticationKey,
    waypoint::Waypoint
};
use libra_crypto::{
    test_utils::KeyPair,
};
use reqwest::Url;
use anyhow::Error;
use crate::block::parse_block_height;

pub fn resubmit_backlog(home: PathBuf, config: &MinerConfig){
    //! If there are any proofs which have not been verified on-chain, send them.
    
    // Getting remote miner state
    let tx_params = get_params_from_swarm(home).unwrap();
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();
    let remote_state: MinerStateView  = match client.get_miner_state(tx_params.address.clone()) {
        Ok( s ) => { match s {
            Some(state) => state,
            None=> {
                println!("No remote state found");
                return
            }
        } },
        Err( e) => {
            println!("error: {:?}", e);
            return
        },
    };

    let remote_height = remote_state.verified_tower_height;

    println!("Remote tower height: {}", remote_height);

    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.chain_info.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);

    println!("Current tower height: {:?}", current_block_number);
    for entry in glob(&format!("{}/block_0.json", blocks_dir.display()))
            .expect("Failed to read glob pattern")
    {
        if let Ok(entry) = entry {
            let file = File::open(&entry).expect("Could not open block file");
            let reader = BufReader::new(file);
            let block: Block = serde_json::from_reader(reader).unwrap();
            let res = submit_tx(&tx_params, block.preimage, block.data, false);
            printn!("Result: {:?}", res);
        }
    }
}
