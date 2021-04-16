//! `bal` subcommand

use std::path::PathBuf;
use cli::{libra_client::LibraClient};
use reqwest::Url;
use libra_types::{waypoint::Waypoint};
use anyhow::Error;
use anyhow::{Result};
use crate::{entrypoint, node_health::NodeHealth, prelude::app_config};

/// returns a LibraClient instance.
// TODO: Use app config file for params
pub fn make_client(url: Option<Url>, waypoint: Waypoint) -> Result<LibraClient, Error> { 
    Ok(LibraClient::new(
        url.clone().unwrap_or("http://localhost:8080".to_owned().parse().unwrap()),
        waypoint
    ).unwrap())
}

/// Experimental
pub fn get_client() -> Option<LibraClient> {
    let entry_args = entrypoint::get_args();
    // if url and waypoint provided as fn params 
    //     return LibraClient::new(url, waypoint);

    // if local node in-sync 
    //    return default_local_client()
    // else find and return connect-able upstream node
    let config = app_config();
    let waypoint = config.get_waypoint(entry_args.swarm_path).expect("could not get waypoint");
    for url in config.profile.upstream_nodes.as_ref().unwrap() {
        let mut client = LibraClient::new(url.clone(), waypoint).unwrap();
        // TODO: What's the better way to check we can connect to client?
        let metadata = client.get_metadata();
        dbg!(&metadata);
        if metadata.is_ok() {   // found a connect-able upstream node
            return Some(client);
        }
    }

    None
}

/// get client type with defaults from toml for remote node
pub fn default_remote_client()  ->(Result<LibraClient, Error>, Url){
    // let entry_args = entrypoint::get_args();

    let config = app_config();
    let remote_url = config.profile.upstream_nodes.clone().unwrap().into_iter().next().unwrap(); // upstream_node_url.clone();
    let waypoint = config.get_waypoint(None).expect("could not get waypoint");
    (make_client(Some(remote_url.clone()), waypoint), remote_url)
}

/// get client type with defaults from toml for local node
pub fn default_local_client()  -> (Result<LibraClient, Error>, Url){
    // let entry_args = entrypoint::get_args();
    let config = app_config().to_owned();
    let local_url = config.profile.default_node.clone().expect("could not get url from configs");
    let waypoint = config.get_waypoint(None).expect("could not get waypoint");
    (make_client(Some(local_url.clone()), waypoint), local_url)
}

/// connect a swarm client
pub fn swarm_test_client(swarm_path: PathBuf) -> LibraClient {
    let (url, waypoint) = ol_util::swarm::get_configs(swarm_path);
    make_client(Some(url), waypoint).expect("could not connect swarm client")
}

/// picks what URL to connect to based on sync state. Or returns the client for swarm.
pub fn pick_client(swarm_path: Option<PathBuf>) -> LibraClient {
    if let Some(path) = swarm_path {
      return swarm_test_client(path)
    };

    // check if is in sync
    let is_synced: bool = NodeHealth::node_is_synced().0;
    let client_tuple = 
      if is_synced { default_local_client() }
      else         { default_remote_client() };
    client_tuple.0.expect("could not configure a client")
}