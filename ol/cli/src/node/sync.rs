//! `sync` subcommand

use super::node::Node;
use crate::{config::AppCfg, node::client::*};
use anyhow::Error;
use cli::libra_client::LibraClient;
use libra_types::waypoint::Waypoint;

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
  pub fn is_synced(&mut self) -> (bool, i64) {
    if !Node::node_running() {
      return (false, 0);
    };
    let wp = self.waypoint().expect("Can not update Waypoint");
    let mut remote_client = default_remote_client(&self.conf, wp).unwrap().0;
    //println!("remote: {:?}", &self.conf);
    let delay = compare_client_version(&mut self.client, &mut remote_client).unwrap();
    (within_thresh(delay), delay)
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
