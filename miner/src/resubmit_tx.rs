//! OlMiner resubmit_tx module
#![forbid(unsafe_code)]

use cli::{libra_client::LibraClient};
use std::fs::File;
use glob::glob;
use crate::{block::Block};
use std::io::BufReader;
use libra_json_rpc_types::views::MinerStateView;
use std::path::PathBuf;
//use crate::submit_tx::LocalMinerState;
use crate::config::OlMinerConfig;
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
use crate::block::build_block::parse_block_height;

pub fn resubmit_backlog(home: PathBuf, config: &OlMinerConfig){
    //! If there are any proofs which have not been verified on-chain, send them.
    
    // Getting remote miner state
    let tx_params = get_params_from_swarm(home).unwrap();
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

    println!("Current block number: {:?}", current_block_number);
    for entry in glob(&format!("{}/block_0.json", blocks_dir.display()))
            .expect("Failed to read glob pattern")
        {
            if let Ok(entry) = entry {
                let file = File::open(&entry).expect("Could not open block file");
                let reader = BufReader::new(file);
                let block: Block = serde_json::from_reader(reader).unwrap();
                let res = submit_tx(&tx_params, block.preimage, block.data, block.height);
                println!("Result: {:?}", res);
            }
    }
    // Open the file in read-only mode with buffer.
    // let file = File::open(&blocks_dir + "").expect("local state file does not exists");
    // let reader = BufReader::new(file);
    // let local_state: LocalMinerState = serde_json::from_reader(reader).expect("Can deserilize local state file.");


    // // 1. Find the most recent LOCAL tower height. We can store this in a json file.
    // // Open the file in read-only mode with buffer.
    // let file = File::open(path).expect("local state file does not exists");
    // let reader = BufReader::new(file);
    // let local_state: LocalMinerState = serde_json::from_reader(reader).expect("Can deserilize local state file.");

    // println!("Reading local miner state");

    // let local_tower_height = local_state.local_tower_height;
    // let last_succesful_tx_height = local_state.last_succesful_tx_height;

    // // 1a. Check if there is a resubmission in progress. Exit gracefully.
    // if local_state.retrying_height > 0 { return }

    // // 1b. quickly check if there is a problem, from local state.
    // if quick_check && (last_succesful_tx_height < local_tower_height) {
    //    println!("Your tower appears ahead ahead of chain by {}. Not attempting resubmission. Run withouth quick_check == true to resubmit.", local_tower_height - last_succesful_tx_height)
    // }
    // // 2. Query network for most recent reported_tower_height of the user.
    // // let mut libra_client = ClientProxy::new_for_ol(
    // //     /* url */ &node,
    // //     /* mnemonic file */ &mnemonic_string,
    // //     /* waypoint */ waypoint,
    // // )

    // let sender_account = client.accounts[0].address;
    // let remote_state: MinerStateView  = match client.get_miner_state(sender_account) {
    //     Ok( s ) => { match s {
    //         Some( state) => state,
    //         None=> {
    //             println!("No remote state found");
    //             return
    //         }
    //     } },
    //     Err( e) => {
    //         println!("error: {:?}", e);
    //         return
    //     },
    // };
    // let remote_height = remote_state.verified_tower_height;

    // //3. Use Block::submit_block() to submit the oldest proof NOT registered onchain.
    // if remote_height < local_tower_height {
    //     // let mut file = fs::File::open(&entry).expect("Could not open block file");
    //     // let reader = BufReader::new(file);
    //     // let missing_block: Block = serde_json::from_reader(reader).unwrap();
    //     // crate::block::submit_block( missing_block , etc. )
    // }

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