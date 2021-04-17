//! `bal` subcommand

use crate::{check::items::Items, config::OlCliConfig, node::client::*};
use cli::libra_client::LibraClient;
use libra_json_rpc_client::views::MetadataView;
use libra_types::waypoint::Waypoint;
use reqwest::Url;
use super::node::Node;

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
        let mut remote_client = default_remote_client(&self.conf, wp).0.unwrap();
        let delay = Node::compare_client_version(
          &mut self.client,
          &mut remote_client
        );
        (within_thresh(delay), delay)
    }
    // /// returns a LibraClient instance.
    // // TODO: Use app config file for params
    // pub fn new(url: &Url, client: &mut LibraClient) -> Self {
    //     match client.get_metadata() {
    //         Ok(meta) => {
    //             Metadata {
    //                 url: url.clone(),
    //                 meta: Some(meta)
    //             }
    //         }
    //         Err(_) => {
    //             Metadata {
    //                 url: url.clone(),
    //                 meta: None
    //             }
    //         }
    //     }

    // }

    // /// Compare the metadata of a local and a remote node
    // pub fn compare(local: MetadataView, remote: MetadataView) -> i64 {
    //     let delay: i64 =  remote.version as i64 - local.version as i64;
    //     delay
    // }

    /// Compare the nodes from toml config.
    pub fn compare_from_config(config: &OlCliConfig, waypoint: Waypoint) -> Option<i64> {
        let local_client = default_local_client(config, waypoint).0;

        let remote_client = default_remote_client(config, waypoint).0;

        if local_client.is_ok() && remote_client.is_ok() {
            return Some(Node::compare_client_version(
                &mut local_client.unwrap(),
                &mut remote_client.unwrap(),
            ));
        }
        None
    }

    pub fn compare_client_version(local: &mut LibraClient, remote: &mut LibraClient) -> i64 {
        let local_version = local.get_metadata().unwrap().version;

        let remote_version = remote.get_metadata().unwrap().version;

        remote_version as i64 - local_version as i64
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

fn within_thresh(delay: i64) -> bool {
  delay < 10_000
}