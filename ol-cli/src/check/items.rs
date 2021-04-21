
// use crate::cache::{DB_CACHE, DB_CACHE_READ};
use std::str;
use serde::{Deserialize, Serialize};
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// Steps needed to initialize a miner
pub struct Items {
  /// node configs created
  pub configs_exist: bool,
  /// current epoch
  pub db_restored: bool,
  /// account created
  pub account_created: bool,
  /// node running
  pub node_running: bool,
  /// miner running
  pub miner_running: bool,
  /// is the blockchain in sync with upstream
  pub is_synced: bool,
  /// how far behind is the node
  pub sync_delay: i64,
  /// is in the validator set
  pub validator_set: bool,
}

impl Default for Items {
  fn default() -> Self {
    Self {
      configs_exist: false,
      db_restored: false,
      account_created: false,
      node_running: false,
      miner_running: false,
      is_synced: false,
      sync_delay: 0,
      validator_set: false,
    }
  }
}

impl Items {
  /// Get new object
  pub fn new(is_synced: bool) -> Self {
    Self {
      is_synced,
      ..Self::default()
    }
  }

  // /// Returns object in init state
  // pub fn init() -> Items {
  //   //TODO: Check if db exists
  //   let items = Items::new(false);

  //   // check if we can read the data, otherwise, init
  //   match DB_CACHE_READ.get(ITEMS_KEY) {
  //       Ok(_) => {}
  //       Err(_) => {
  //         // initialize the cache.
  //         items.write_cache();
  //       }
  //   }
  //   items
  // }

  // /// Saves the Items to cache
  // pub fn write_cache(&self) {
  //   let serialized = serde_json::to_vec(&self.clone()).unwrap();
  //   match DB_CACHE.put(ITEMS_KEY, serialized) {
  //     Ok(_) => {}
  //     Err(err) => {
  //       dbg!(&err);
  //     }
  //   };
  // }

  // /// Get from cache
  // pub fn read_cache() -> Option<Items> {
  //   let q = DB_CACHE_READ.get("items").unwrap().unwrap();
  //   match serde_json::from_slice(&q.as_slice()) {
  //     Ok(items) => Some(items),
  //     Err(_) => None,
  //   }
  // }
}