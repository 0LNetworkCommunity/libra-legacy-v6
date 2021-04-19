//! `cache`
use std::{fs::{self, File}, io::Write};
use serde::{Deserialize, Serialize};
use crate::{check::items::Items, mgmt::management::HostProcess, node::{account::OwnerAccountView, chain_info::ChainView, node::Node, states::HostState}};
use anyhow::Error;
use once_cell::sync::Lazy;
use rocksdb::{Options, DB};
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


impl Node {
    /// reach the json cache
    pub fn read_json(&mut self) -> Vitals {
        let cache_path = self.conf.workspace.node_home.join(CACHE_JSON_NAME);

        let file = fs::File::open(cache_path)
        .expect("file should open read only");
        let json: Vitals = serde_json::from_reader(file)
        .expect("file should be proper JSON");

        json
    }

    /// write json cache
    pub fn write_json(&mut self) -> Result<(), Error> {
        // let json = Vitals {
        //     items: self.vitals.items.clone(),
        //     account_view: self.vitals.account_view.clone(),
        //     chain_view: self.vitals.chain_view.clone(),
        //     node_proc: self.vitals.node_proc.clone(),
        //     miner_proc: self.vitals.miner_proc.clone(),
        //     monitor_proc: self.vitals.monitor_proc.clone(),
        // };

        let serialized = serde_json::to_vec_pretty(&self.vitals)?;
        let cache_path = self.conf.workspace.node_home.join(CACHE_JSON_NAME);
        let mut file = File::create(cache_path)?;
        file.write_all(&serialized)?;
        Ok(())
    }
}


/// Construct Lazy Database instance
pub static DB_CACHE: Lazy<DB> = Lazy::new(|| DB::open_default(MONITOR_DB_PATH).unwrap());

/// use read only access to cli cache
pub static DB_CACHE_READ: Lazy<DB> =
    Lazy::new(|| DB::open_for_read_only(&Options::default(), MONITOR_DB_PATH, true).unwrap());
