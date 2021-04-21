//! `cache`
use crate::{
    check::items::Items,
    mgmt::management::HostProcess,
    node::{account::OwnerAccountView, chain_info::ChainView, states::HostState},
};
use anyhow::Error;
use serde::{Deserialize, Serialize};
use std::{fs::{self, File}, io::Write, path::PathBuf};
/// caching database name, to be appended to node_home
pub const MONITOR_DB_PATH: &str = "/tmp/0L/monitor_db";
/// filename for monitor cache
pub const CACHE_JSON_NAME: &str = "monitor_cache.json";

/// format for storing node data to json
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Vitals {
    ///
    pub items: Items,
    ///
    pub account_view: OwnerAccountView,
    ///
    pub chain_view: Option<ChainView>,
    ///
    pub node_proc: Option<HostProcess>,
    ///
    pub miner_proc: Option<HostProcess>,
    ///
    pub monitor_proc: Option<HostProcess>,
    /// state of the host for state machine
    pub host_state: HostState,
}

impl Vitals {
    /// reach the json cache
    pub fn read_json(node_home: &PathBuf) -> Vitals {
        // let cache_path = self.conf.workspace.node_home.join(CACHE_JSON_NAME);
        let cache_path = node_home.join(CACHE_JSON_NAME);

        let file = fs::File::open(cache_path).expect("file should open read only");
        let deser: Vitals = serde_json::from_reader(file).expect("file should be proper JSON");

        deser
    }

    /// write json cache
    pub fn write_json(&self, node_home: &PathBuf) -> Result<(), Error> {
        let serialized = serde_json::to_vec(&self)?;
        let cache_path = node_home.join(CACHE_JSON_NAME);
        let mut file = File::create(cache_path)?;
        file.write_all(&serialized)?;
        Ok(())
    }
}

// Construct Lazy Database instance
// pub static DB_CACHE: Lazy<DB> = Lazy::new(|| DB::open_default(MONITOR_DB_PATH).unwrap());

// /// use read only access to cli cache
// pub static DB_CACHE_READ: Lazy<DB> =
//     Lazy::new(|| DB::open_for_read_only(&Options::default(), MONITOR_DB_PATH, true).unwrap());
