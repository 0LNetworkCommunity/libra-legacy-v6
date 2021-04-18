//! `sync` subcommand

use super::node::Node;
use crate::{check::items::Items, config::OlCliConfig, node::client::*};
use cli::libra_client::LibraClient;
use libra_types::waypoint::Waypoint;

impl Node {
  /// check if node is synced
  pub fn cold_start_is_synced(config: &OlCliConfig, waypoint: Waypoint) -> (bool, Option<i64>) {
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
    let wp = self.waypoint();
    let mut remote_client = default_remote_client(&self.conf, wp).unwrap().0;
    let delay = compare_client_version(&mut self.client, &mut remote_client);
    (within_thresh(delay), delay)
  }

  /// Compare the nodes from toml config.
  pub fn compare_from_config(config: &OlCliConfig, waypoint: Waypoint) -> Option<i64> {
    let local_client = default_local_client(config, waypoint);

    let remote_client = default_remote_client(config, waypoint);

    if local_client.is_some() && remote_client.is_some() {
      return Some(compare_client_version(
        &mut local_client.unwrap().0,
        &mut remote_client.unwrap().0,
      ));
    }
    None
  }
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
}

fn compare_client_version(local: &mut LibraClient, remote: &mut LibraClient) -> i64 {
  let local_version = local.get_metadata().unwrap().version;
  let remote_version = remote.get_metadata().unwrap().version;
  remote_version as i64 - local_version as i64
}

fn within_thresh(delay: i64) -> bool {
  delay < 10_000
}
