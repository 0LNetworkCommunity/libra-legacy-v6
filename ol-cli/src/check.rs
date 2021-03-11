//! `check` module

use cli::libra_client::LibraClient;
use reqwest::Url;
// use anyhow::Error;
// use anyhow::{Result};
use libra_json_rpc_client::views::MetadataView;
use sled::IVec;
use crate::{client::*, management, metadata::Metadata};

const CHECK_DB: &str = "/tmp/ol-system-checks";
const SYNC_KEY: &str = "is_synced";

/// Persist Checks state
pub fn write_db(key: &str, value: &str) {
    let tree = sled::open(CHECK_DB).expect("open");
    tree.insert(key.as_bytes(), value).unwrap();
}

/// Read Checks state
pub fn read_db(key: &str) -> IVec {
    let tree = sled::open(CHECK_DB).expect("open");
    tree.get(key).unwrap().unwrap()
}

/// Checks we want to make on the node
pub struct Check {}

impl Check {
    /// nothing is configured yet, empty box
    pub fn is_clean_start() -> bool {
        // check to see no files are present
        true
    }

    /// the owner and operator accounts exist on chain
    pub fn accounts_exist_on_chain() -> bool {
        // check to see no files are present
        true
    }

    /// database is initialized
    pub fn database_bootstrapped() -> bool {
        true
    }

    /// Checks if node is synced
    pub fn node_is_synced() -> bool {
        Metadata::compare_from_config() < 1000
    }

    /// Check if node caught up, if so mark as caught up.
    pub fn check_sync() -> bool {
        let sync = Check::node_is_synced();
        // let have_ever_synced = false;
        // assert never synced
        if Check::has_never_synced() && sync {
            // mark as synced
            write_db(SYNC_KEY, "true");
        }
        sync  
    }

    /// check if the node has ever synced
    pub fn has_never_synced() -> bool {
        read_db(SYNC_KEY) != b"true"
    }

    /// node started sync
    pub fn node_started_sync() -> bool {
        read_db(SYNC_KEY) == b"true"
    }

    /// node is running
    pub fn node_is_running() -> bool {
        true
    }

    /// miner is running
    pub fn miner_is_mining() -> bool {
        true
    }
}

/// Collects a pipeline of triggers for onboarding
pub fn onboarding_triggers() {
    // Validator just started setting up machine
    if Check::is_clean_start() {
        management::fast_forward_db();
        return
    }
    // Restore was successful, can start syncing
    if  Check::database_bootstrapped() && !Check::node_is_running() { 
        management::start_node(management::NodeType::Validator);
        return 
    }

    // Validator account is created on chain, can start mining
    if  Check::accounts_exist_on_chain()
    && Check::database_bootstrapped()
    && Check::node_is_running() 
    && Check::node_is_synced() // not 
    && !Check::miner_is_mining() {
        management::start_miner();
        return
    }
    // Node has caught up to rest of network
    if  Check::node_is_synced() && !Check::miner_is_mining() {
        management::start_miner();
        return
    }

        // Node has caught up to rest of network
    if  Check::node_is_synced() && !Check::miner_is_mining() {
        management::start_miner();
        return
    }
}