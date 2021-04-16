//! `check` module
use super::transitions;

use crate::{
  application::app_config,
  config::OlCliConfig,
  cache::DB_CACHE,
  entrypoint,
  node::metadata::Metadata,
  check::items::Items,
};
use anyhow::Error;
use cli::libra_client::LibraClient;
use libradb::LibraDB;
use std::{str, convert::TryFrom};
use sysinfo::SystemExt;

use libra_json_rpc_client::views::MinerStateResourceView;
use libra_types::waypoint::Waypoint;
use libra_types::{account_address::AccountAddress, account_state::AccountState};
use storage_interface::DbReader;

use super::states::HostState;

/// name of key in kv store for sync
pub const SYNC_KEY: &str = "is_synced";

/// node process name:
pub const NODE_PROCESS: &str = "libra-node";

/// miner process name:
pub const MINER_PROCESS: &str = "miner";


/// Configuration used for checks we want to make on the node
pub struct Node {
  /// 0L configs
  pub conf: OlCliConfig,
  /// libraclient for connecting
  pub client: Option<LibraClient>,
  /// all items we are checking. Monitor sends these to cache.
  pub items: Items,
  pub host_state: HostState,
  chain_state: Option<AccountState>,
  miner_state: Option<MinerStateResourceView>,
}

impl Node {
  /// Create a instance of Check
  pub fn new(client: Option<LibraClient>, conf: OlCliConfig) -> Self {
    return Self {
      client,
      conf,
      host_state: HostState::init(),
      items: Items::init(),
      miner_state: None,
      chain_state: None,
    };
  }

  /// refresh all checks
  pub fn refresh_checks(&mut self) -> Items {
    self.items.configs_exist = self.configs_exist();
    self.items.db_restored = self.database_bootstrapped();
    self.items.node_running = Node::node_running();
    self.items.miner_running = Node::miner_running();
    self.items.account_created = self.accounts_exist_on_chain();
    let sync_tuple = Node::node_is_synced(&self.conf);

    self.items.is_synced = sync_tuple.0;
    self.items.sync_delay = sync_tuple.1;
    self.items.validator_set = self.is_in_validator_set();
    self.items.clone()
  }

  fn get_annotate_account_blob(
    &mut self,
    address: AccountAddress,
  ) -> Result<AccountState, Error> {
    let (blob, _ver) = self.client.clone().unwrap().get_account_state_blob(address)?;
    if let Some(account_blob) = blob {
      Ok(AccountState::try_from(&account_blob).unwrap())
    } else {
      Err(Error::msg("connection to client"))
    }
  }

  /// Fetch chain state from the upstream node
  pub fn fetch_upstream_states(&mut self) {
    self.chain_state = match self.get_annotate_account_blob(AccountAddress::ZERO) {
      Ok(account_state) => Some(account_state),
      Err(_) => None,
    };
    self.miner_state = match self.client.clone().unwrap().get_miner_state(self.conf.profile.account) {
      Ok(state) => state,
      _ => None,
    }
  }

  /// return tower height on chain
  pub fn tower_height_on_chain(&self) -> u64 {
    match &self.miner_state {
      Some(s) => s.verified_tower_height,
      None => 0,
    }
  }

  /// return tower height on chain
  pub fn mining_epoch_on_chain(&self) -> u64 {
    match &self.miner_state {
      Some(s) => s.latest_epoch_mining,
      None => 0,
    }
  }

  // /// return  height on chain
  // pub fn chain_height(&mut self) -> u64 {
  //     match self.client.get_metadata() {
  //         Ok(m) => {
  //             self.items.height = m.version;
  //             m.version
  //         }
  //         Err(_) => 0
  //     }
  // }

  // /// return epoch on chain
  // pub fn epoch_on_chain(&mut self)-> u64 {
  //     match &self.chain_state {
  //         Some(s) => {
  //             let epoch = s.get_configuration_resource().unwrap().unwrap().epoch();
  //             self.items.epoch = epoch;
  //             epoch
  //         },
  //         None => 0
  //     }
  // }
  /// validator sets
  pub fn validator_set_count(&self) -> usize {
    match &self.chain_state {
      Some(s) => s.get_validator_set().unwrap().unwrap().payload().len(),
      None => 0,
    }
  }

  /// Current monitor account
  pub fn account(&self) -> Vec<u8> {
    self.conf.profile.account.to_vec()
  }

  // TODO: duplicated with Check
  /// Current monitor account
  pub fn waypoint(&mut self) -> Waypoint {
    let entry_args = entrypoint::get_args();
    self.client.clone()
      .unwrap() 
      .get_state_proof()
      .expect("Failed to get state proof"); // refresh latest state proof
    let waypoint = self.client.clone().unwrap().waypoint();
    match waypoint {
      Some(w) => {
        //self.client = LibraClient::new(self.conf.node_url.clone(), w.clone()).unwrap();
        w
      }
      None => self
        .conf
        .get_waypoint(entry_args.swarm_path)
        .expect("could not get waypoint"),
    }
  }

  /// is validator jailed
  pub fn is_jailed() -> bool {
    unimplemented!("Don't know how to implement")
  }

  /// Is current account in validator set
  pub fn is_in_validator_set(&self) -> bool {
    match &self.chain_state {
      Some(s) => {
        for v in s.get_validator_set().unwrap().unwrap().payload().iter() {
          if v.account_address().to_vec() == self.conf.profile.account.to_vec() {
            return true;
          }
        }
        false
      }
      None => false,
    }
  }

  /// nothing is configured yet, empty box
  pub fn configs_exist(&mut self) -> bool {
    // check to see no files are present
    let home_path = self.conf.workspace.node_home.clone();

    let c_exist = home_path.join("blocks/block_0.json").exists()
      && home_path.join("validator.node.yaml").exists()
      && home_path.join("key_store.json").exists();
    c_exist
  }

  /// the owner and operator accounts exist on chain
  pub fn accounts_exist_on_chain(&mut self) -> bool {
    let addr = self.conf.profile.account;
    // dbg!(&addr);
    let account = self.client.clone().unwrap().get_account(addr, false);
    match account {
      Ok((opt, _)) => match opt {
        Some(_) => true,
        None => false,
      },
      Err(_) => false,
    }
  }

  /// database is initialized, Please do NOT invoke this function frequently
  pub fn database_bootstrapped(&mut self) -> bool {

    let mut file = self.conf.workspace.node_home.clone();
    file.push("db/libradb"); // TODO should the name be hardcoded here?
    if file.exists() {
      // When not committing, we open the DB as secondary so the tool is usable along side a
      // running node on the same DB. Using a TempPath since it won't run for long.
      // let tmpdir = TempPath::new();
      match LibraDB::open(file, true, None) {
        Ok( db)=>{
          println!("opened db");
          return db.get_latest_version().is_ok()
        },
        Err(_)=> { 
          println!("err db");

        }
      }
    }
    return false;
  }

  /// check if node is synced
  pub fn node_is_synced(config: &OlCliConfig) -> (bool, i64) {
    if !Node::node_running() {
      return (false, 0);
    };
    let delay = Metadata::compare_from_config(config);
    (delay < 10_000, delay)
  }

    /// check if node is synced
  pub fn is_synced(&self) -> (bool, i64) {
    if !Node::node_running() {
      return (false, 0);
    };
    let delay = Metadata::compare_from_config(&self.conf);
    (delay < 10_000, delay)
  }

  // /// Check if node caught up, if so mark as caught up.
  // pub fn check_sync(&mut self) -> (bool, i64) {
  //     let sync = Check::node_is_synced();
  //     // let have_ever_synced = false;
  //     // assert never synced
  //     if self.has_never_synced() && sync.0 {
  //         // mark as synced
  //         self.items.is_synced = true;
  //         self.items.write_cache();
  //     }
  //     sync
  // }

  /// Check if the node has ever synced
  pub fn has_never_synced(&self) -> bool {
    match Items::read_cache() {
      Some(i) => !i.is_synced,
      None => true,
    }
  }

  /// Check if node started sync
  pub fn node_started_sync(&self) -> bool {
    match Items::read_cache() {
      // has anything in the cache state
      Some(_) => true,
      None => false,
    }
  }

  // /// Check if node is running
  // pub fn check_node_state() -> bool {
  //   NodeHealth::check_process(NODE_PROCESS)
  // }
  /// Check if node is running
  pub fn node_running() -> bool {
    Node::check_process(NODE_PROCESS)
  }

  /// Check if miner is running
  pub fn miner_running() -> bool {
    Node::check_process(MINER_PROCESS)
  }

  fn check_process(process_str: &str) -> bool {
    let mut system = sysinfo::System::new_all();
    system.refresh_all();

    use sysinfo::ProcessExt;
    for (_, process) in system.get_processes() {
      if process.name() == process_str {
        return true;
      }
    }

    false
  }

  // /// get blockchain height
  // pub fn get_height(&mut self) -> u64 {

  //     let m = Metadata::new(
  //         &self.conf.profile.default_node.clone().unwrap(),
  //         &mut self.client
  //     );
  //     if let Some(mv) = m.meta {
  //        return mv.version
  //     }
  //     0
  // }
}
