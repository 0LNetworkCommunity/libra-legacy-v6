//! `check` module

use cli::libra_client::LibraClient;
use sysinfo::SystemExt;
use crate::metadata::Metadata;
use crate::config::OlCliConfig;
use crate::application::app_config;
use std::str;
use rocksdb::DB;
use serde::{Serialize, Deserialize};

/// caching database name, to be appended to node_home
pub const CHECK_CACHE_PATH: &str = "ol-system-checks";

/// name of key in kv store for sync
pub const SYNC_KEY: &str = "is_synced";
/// Return the DB object
pub fn cache_handle() -> DB {
    let mut conf = app_config().to_owned();
    conf.home_path.push(CHECK_CACHE_PATH);
    DB::open_default(conf.home_path).unwrap()
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// Steps needed to initialize a miner
pub struct Items {
    /// is the blockchain in sync with upstream
    pub is_synced: bool,
}

impl Items {
    /// Get new object
    pub fn new(is_synced: bool) -> Self {
        Items {
            is_synced,
        }
    }

    /// Returns object in init state
    pub fn init() -> Items {
        //TODO: Check if db exists
        let items = Items::new(false);
        items.write_cache();
        items
    }

    /// Saves the Items to cache
    pub fn write_cache(&self) {
        let serialized = serde_json::to_vec(&self).unwrap();
        match cache_handle().put("items", serialized) {
            Ok(_) => {}
            Err(err) => {dbg!(&err);}
        }; 
    }

    
    /// Get from cache
    pub fn read_cache() -> Option<Items>{
        let q = cache_handle().get("items").unwrap().unwrap();
        match serde_json::from_slice(&q.as_slice()) {
            Ok(items) => {
                Some(items)
            }
            Err(_) => {None}
        }
    }
}



/// Configuration used for checks we want to make on the node
pub struct Check {
    conf: OlCliConfig,
    client: LibraClient,
    miner_process_name: &'static str,
    node_process_name: &'static str,
    items: Items,
}


impl Check {
    /// Create a instance of Check
    pub fn new() -> Self {
        let conf = app_config().to_owned();

        return Self {
            client: LibraClient::new(conf.node_url.clone(), conf.base_waypoint.clone()).unwrap(),
            conf,
            miner_process_name: "miner",
            node_process_name: "libra-node",
            items: Items::init(),
        }
    }


    /// nothing is configured yet, empty box
    pub fn is_clean_start(&self) -> bool {
        // check to see no files are present
        let mut file = self.conf.home_path.clone();
        file.push("blocks/block_0.json"); //TODO change file name later
        !file.exists()
    }

    /// the owner and operator accounts exist on chain
    pub fn accounts_exist_on_chain(&mut self) -> bool {
        // check to see no files are present
        let x = self.client.get_account(self.conf.address, false);
        //println!("Account address: {}", &self.conf.address);
        match x {
            Ok((opt,_)) => match opt{
                Some(_) => true,
                None => false
            },
            Err(err) => panic!("Error: {}", err),
        }
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
    pub fn check_sync(&mut self) -> bool {
        let sync = Check::node_is_synced();
        // let have_ever_synced = false;
        // assert never synced
        if self.has_never_synced() && sync {
            // mark as synced
            self.items.is_synced = true;
            self.items.write_cache();
        }
        sync  
    }

    /// check if the node has ever synced
    pub fn has_never_synced(&self) -> bool {
        match Items::read_cache() {
            Some(i) => {!i.is_synced}
            None => {true}
        }
    }

    /// node started sync
    pub fn node_started_sync(&self) -> bool {
        match Items::read_cache() {
            // TODO: Use has_started_sync
            Some(i) => {!i.is_synced}
            None => {true}
        }
    }

    /// node is running
    pub fn node_is_running(&self) -> bool {
        let mut system = sysinfo::System::new_all();

        // First we update all information of our system struct.
        system.refresh_all();
        let ps = system.get_process_by_name(self.node_process_name );
        ps.len() > 0
    }

    /// miner is running
    pub fn miner_is_mining(&self) -> bool {
        let mut system = sysinfo::System::new_all();

        // First we update all information of our system struct.
        system.refresh_all();
        let ps = system.get_process_by_name(self.miner_process_name);
        ps.len() > 0
    }
}

/// Collects a pipeline of triggers for onboarding
pub fn onboarding_triggers() {
    // Validator just started setting up machine
    // if Check::is_clean_start() {
    //     management::fast_forward_db();
    //     return
    // }
    // // Restore was successful, can start syncing
    // if  Check::database_bootstrapped() && !Check::node_is_running() {
    //     management::start_node(management::NodeType::Validator);
    //     return
    // }
    //
    // // Validator account is created on chain, can start mining
    // if  Check::accounts_exist_on_chain()
    // && Check::database_bootstrapped()
    // && Check::node_is_running()
    // && Check::node_is_synced() // not
    // && !Check::miner_is_mining() {
    //     management::start_miner();
    //     return
    // }
    // // Node has caught up to rest of network
    // if  Check::node_is_synced() && !Check::miner_is_mining() {
    //     management::start_miner();
    //     return
    // }
    //
    //     // Node has caught up to rest of network
    // if  Check::node_is_synced() && !Check::miner_is_mining() {
    //     management::start_miner();
    //     return
    // }
}