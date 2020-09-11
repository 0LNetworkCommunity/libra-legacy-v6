//! OlMiner resubmit_tx module
#![forbid(unsafe_code)]

use cli::{libra_client::LibraClient};
use std::fs::File;
use glob::glob;
use crate::{
    block::Block,
    config::OlMinerConfig,
    submit_tx::{
        TxParams, 
        submit_tx,
        eval_tx_status},
};
use std::io::BufReader;
use libra_json_rpc_types::views::MinerStateView;
use crate::block::build_block::parse_block_height;

/// Submit a backlog of blocks that may have been mined while network is offline. Likely not more than 1. 
pub fn backlog(config: &OlMinerConfig, tx_params: TxParams){
    // Getting remote miner state
    // let tx_params = get_params_from_swarm(home).unwrap();
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();
    let remote_state: MinerStateView  = match client.get_miner_state(tx_params.address.clone()) {
        Ok( s ) => { match s {
            Some( state) => state,
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

    println!("Remote height: {}", remote_height);

    // Getting local state height
    let mut blocks_dir = config.workspace.home.clone();
    blocks_dir.push(&config.chain_info.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);

    println!("Current block number: {:?}", current_block_number.unwrap());
    for i in remote_height+1..current_block_number.unwrap()+1{
        println!("Resubmitting missing block: {}", i);
        for entry in glob(&format!("{}/block_{}.json", blocks_dir.display(), i))
                .expect("Failed to read glob pattern")
            {
                if let Ok(entry) = entry {
                    let file = File::open(&entry).expect("Could not open block file");
                    let reader = BufReader::new(file);
                    let block: Block = serde_json::from_reader(reader).unwrap();
                    let res = submit_tx(&tx_params, block.preimage, block.data, block.height, false);
                    if eval_tx_status(res) == false {
                        break;
                    };
                }
        };
    };
}