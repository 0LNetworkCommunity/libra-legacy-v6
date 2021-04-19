//! `cache`
use std::{fs::File, io::Write};
use serde::{Deserialize, Serialize};
use crate::{
    check::items::Items,
    node::{account::OwnerAccountView, chain_info::ChainView, node::Node},
};
use anyhow::Error;
use once_cell::sync::Lazy;
use rocksdb::{Options, DB};
/// caching database name, to be appended to node_home
pub const MONITOR_DB_PATH: &str = "/tmp/0L/monitor_db";
/// filename for monitor cache
pub const CACHE_JSON_NAME: &str = "monitor_cache.json";

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct CacheFormat {
    items: Items,
    account_view: OwnerAccountView,
    chain_view: Option<ChainView>,
}


impl Node {
    /// reach the json cache
    pub fn read_json(&mut self) -> &mut Self {
        self
    }

    /// write json cache
    pub fn write_json(&mut self) -> Result<(), Error> {
        let json = CacheFormat {
            items: self.items.clone(),
            account_view: self.account_view.clone(),
            chain_view: self.chain_view.clone(),
        };

        let serialized = serde_json::to_vec(&json)?;
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
