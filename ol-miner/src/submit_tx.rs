//! OlMiner submit_tx module
#![forbid(unsafe_code)]

use crate::error::{Error, ErrorKind};
use cli::client_proxy::ClientProxy;
use libra_types::{account_address::AccountAddress, waypoint::Waypoint};
use std::fs::File;
use std::io::BufReader;
use libra_json_rpc_types::views::MinerStateView;
use std::path::Path;
use serde::{Serialize, Deserialize};

// use crate::application::{MINER_MNEMONIC, DEFAULT_PORT};
// const DEFAULT_PORT: u64 = 2344; // TODO: this will likely deprecated in favor of urls and discovery.
                                // const DEFAULT_NODE: &str = "src/config/test_data/single.node.config.toml";
// TODO: I don't think this is being used
// const ASSOCIATION_KEY_FILE: &str = "../0_dev_config/mint.key"; // Empty String or invalid file get converted to a None type in the constructor.

pub fn submit_vdf_proof_tx_to_network(
    challenge: Vec<u8>,
    difficulty: u64,
    proof: Vec<u8>,
    waypoint: Waypoint,
    mnemonic_string: String,
    node: String,
    // max_retries: Some(u64), // TODO (Ping): used below on retries.
) -> Result<(), Error> {
    //! Functions for submitting proofs on chain

    // TODO (ZM): I think this can generate a number of configs including Waypoint.
    // let mut swarm_configs = NodeConfig::load(DEFAULT_NODE).expect("Unable to load config");
    // NOTE (LG): We're using a testing tool ClientProxy so that the miner has
    // its own client connection to network.
    // ClientProxy is an abstraction on top of Libra Client and other modules. (as with all testing tools) is unstable and in develoment.

    // create the ClientProxy, with credentials, and point to network with a waypoint.
    let mut libra_client = ClientProxy::new_for_ol(
        /* url */ &node,
        /* mnemonic file */ &mnemonic_string,
        /* waypoint */ waypoint,
    )
    .map_err(|err| ErrorKind::Wallet.context(err))?;

    //TODO: 0L-miner/submit_tx LibraWallet is not recovering all accounts.
    let sender_account = libra_client.accounts[0].address;

    libra_client
        .execute_send_proof(
            sender_account, // sender: &AccountData,
            challenge,      // challenge: Vec<u8>,
            difficulty,     // difficulty: u64,
            proof,          // proof: Vec<u8>
            true,
        )
        .map_err(|err| ErrorKind::Transaction.context(err))?;

    Ok(())
}


pub fn resubmit_backlog(path: &Path, client: &mut ClientProxy, quick_check: bool){
    //TODO (Ping): If there are any proofs which have not been verified on-chian, send them.

    // 1. Find the most recent LOCAL tower height. We can store this in a json file.
    // Open the file in read-only mode with buffer.
    let file = File::open(path).expect("local state file does not exists");
    let reader = BufReader::new(file);
    let local_state: LocalMinerState = serde_json::from_reader(reader).expect("Can deserilize local state file.");

    let local_tower_height = local_state.local_tower_height;
    let last_succesful_tx_height = local_state.last_succesful_tx_height;

    // 1a. Check if there is a resubmission in progress. Exit gracefully.
    if local_state.retrying_height > 0 { return }

    // 1b. quickly check if there is a problem, from local state.
    if quick_check && (last_succesful_tx_height < local_tower_height) {
       println!("Your tower appears ahead ahead of chain by {}. Not attempting resubmission. Run withouth quick_check == true to resubmit.", local_tower_height - last_succesful_tx_height)
    }
    // 2. Query network for most recent reported_tower_height of the user.
    // let mut libra_client = ClientProxy::new_for_ol(
    //     /* url */ &node,
    //     /* mnemonic file */ &mnemonic_string,
    //     /* waypoint */ waypoint,
    // )

    let sender_account = client.accounts[0].address;
    let remote_state: MinerStateView  = match client.get_miner_state(sender_account) {
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

    //3. Use Block::submit_block() to submit the oldest proof NOT registered onchain.
    if remote_height < local_tower_height {
        // let mut file = fs::File::open(&entry).expect("Could not open block file");
        // let reader = BufReader::new(file);
        // let missing_block: Block = serde_json::from_reader(reader).unwrap();
        // crate::block::submit_block( missing_block , etc. )
    }

}

/// LocalMinerState
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct LocalMinerState {
    pubkey: String,
    local_tower_height: u64,
    last_succesful_tx_height: u64,
    retrying_height: u64, // if there is a resubmission in process, we need to know.
}

/// VDF Proofs
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct VDFProof {
    challenge: Vec<u8>,
    difficulty: u64,
    solution: Vec<u8>, // if there is a resubmission in process, we need to know.
}

/// backlog of LocalMinerState
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Backlog {

}

