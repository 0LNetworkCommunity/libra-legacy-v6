//! `sync` subcommand

use super::node::Node;
use crate::{config::AppCfg, node::client::*};
use anyhow::{Error, anyhow, bail};
use backup_cli::utils::backup_service_client::{BackupServiceClient, BackupServiceClientOpt};
use cli::libra_client::LibraClient;
use libra_types::waypoint::Waypoint;
use libradb::backup::backup_handler::DbState;
use tokio::runtime::Runtime;

impl Node {
  /// check if node is synced
  pub fn cold_start_is_synced(config: &AppCfg, waypoint: Waypoint) -> (bool, Option<i64>) {
    if !Node::node_running() {
      return (false, None);
    };
    match Node::compare_from_config(config, waypoint) {
      Some(delay) => (within_thresh(delay), Some(delay)),
      _ => (false, None),
    }
  }

  /// check if node is synced
  pub fn is_synced(&mut self) -> Result<(bool, i64), Error> {
    if !Node::node_running() {
      bail!("Node is not running. Cannot connect to localhost:8080.");
    }
    
    let wp = self.waypoint().expect("Can not update Waypoint");
    let mut remote_client = default_remote_client(&self.conf, wp).unwrap().0;
    dbg!(&remote_client.get_metadata().unwrap().version);
    dbg!(&self.client.get_metadata().unwrap().version);

    if let Some(local_db) = get_db_state() {
      let remote_version = remote_client.get_metadata().unwrap().version;
      let delay = remote_version as i64 - local_db.synced_version as i64;
      if delay < 1000 {
        return Ok((true, delay))
      } else {
        return Ok((false, delay))
      }
    }
    Err(anyhow!("Cannot get local db state"))
  }

  /// Compare the nodes from toml config.
  pub fn compare_from_config(config: &AppCfg, waypoint: Waypoint) -> Option<i64> {
    let local_client = default_local_client(config, waypoint);
    let remote_client = default_remote_client(config, waypoint);

    if local_client.is_some() && remote_client.is_some() {
      return match compare_client_version(
        &mut local_client.unwrap().0,
        &mut remote_client.unwrap().0,
      ) {
          Ok(delay) => Some(delay),
          Err(_) => None
      }
    }
    None
  }
}

fn compare_client_version(local: &mut LibraClient, remote: &mut LibraClient) -> Result<i64, Error> {
  let local_meta = local.get_metadata()?;
  let remote_meta = remote.get_metadata()?;
  Ok(remote_meta.version as i64 - local_meta.version as i64)
}

fn within_thresh(delay: i64) -> bool {
  delay < 10_000
}

/// get local sync block height
pub fn get_db_state() -> Option<DbState>{
  let bk = BackupServiceClientOpt {
    address: "http://localhost:6186".to_owned(),
  };
  let client = BackupServiceClient::new_with_opt(bk);

  let mut rt = Runtime::new().unwrap();
  rt.block_on(client.get_db_state()).unwrap()
}