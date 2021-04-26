//! `bal` subcommand

use std::path::PathBuf;
use cli::{libra_client::LibraClient};
use reqwest::Url;
use libra_types::{waypoint::Waypoint};
use anyhow::Error;
use anyhow::{Result};
use crate::{config::OlCliConfig, entrypoint, node::node::Node, prelude::app_config};

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
pub fn default_remote_client(config: &OlCliConfig, waypoint: Waypoint)  -> Option<(LibraClient, Waypoint)>{
    let remote_url = config.profile.upstream_nodes.clone().unwrap().into_iter().next().unwrap(); // upstream_node_url.clone();
    match make_client(Some(remote_url.clone()), waypoint) {
      Ok(client) => { Some((client, waypoint)) }
      Err(_) => {None}
    }
}

/// get client type with defaults from toml for local node
pub fn default_local_client(config: &OlCliConfig,  waypoint: Waypoint)  -> Option<(LibraClient, Waypoint)>{
    let local_url = config.profile.default_node.clone().expect("could not get url from configs");
    match make_client(Some(local_url.clone()), waypoint) {
        Ok(client) => { Some((client, waypoint)) }
        Err(_) => {None}
    }
}

/// connect a swarm client
pub fn swarm_test_client(swarm_path: PathBuf) -> Option<(LibraClient, Waypoint)> {
    let (url, waypoint) = ol_types::config::get_swarm_configs(swarm_path);
    match make_client(Some(url), waypoint) {
        Ok(client) => {Some((client, waypoint))}
        Err(_) => {None}
    }
}

/// picks what URL to connect to based on sync state. Or returns the client for swarm.
pub fn pick_client(swarm_path: Option<PathBuf>, config: &OlCliConfig) -> Option<(LibraClient, Waypoint)> {
    if let Some(path) = swarm_path {
      return swarm_test_client(path);
    };
    let waypoint = config.get_waypoint(swarm_path).expect("could not get waypoint");
    // check if is in sync
    let is_synced: bool = Node::cold_start_is_synced(config, waypoint).0;
    match is_synced { 
      true => default_local_client(config, waypoint.clone()),
      _ => default_remote_client(config, waypoint.clone())
    }
}