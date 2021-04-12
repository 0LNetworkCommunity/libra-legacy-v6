//! `cache`
use rocksdb::DB;
use once_cell::sync::Lazy;
use crate::prelude::app_config;

/// caching database name, to be appended to node_home
pub const CACHE_PATH: &str = "ol-system-checks";

/// Construct Lazy Database instance
pub static DB_CACHE: Lazy<DB> = Lazy::new(||{
    let mut conf = app_config().to_owned();
    conf.workspace.node_home.push(CACHE_PATH);
    DB::open_default(conf.workspace.node_home).unwrap()
});

