//! `bal` subcommand

use crate::{config::AppCfg, entrypoint, node::node::Node, prelude::app_config};
use anyhow::Error;
use anyhow::Result;
use cli::libra_client::LibraClient;
use libra_types::waypoint::Waypoint;
use reqwest::Url;
use std::path::PathBuf;

/// returns a LibraClient instance.
// TODO: Use app config file for params
pub fn make_client(url: Option<Url>, waypoint: Waypoint) -> Result<LibraClient, Error> {
    match url {
        Some(u) => LibraClient::new(u, waypoint),
        None => LibraClient::new(
            Url::parse("http://localhost:8080").expect("Couldn't create libra client"),
            waypoint,
        ),
    }
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
    let waypoint = config
        .get_waypoint(entry_args.swarm_path)
        .expect("could not get waypoint");
    for url in config.profile.upstream_nodes.as_ref().unwrap() {
        let mut client = LibraClient::new(url.clone(), waypoint).unwrap();
        // TODO: What's the better way to check we can connect to client?
        let metadata = client.get_metadata();
        dbg!(&metadata);
        if metadata.is_ok() {
            // found a connect-able upstream node
            return Some(client);
        }
    }

    None
}

/// get client type with defaults from toml for remote node
pub fn default_remote_client(
    config: &AppCfg,
    waypoint: Waypoint,
) -> Result<(LibraClient, Waypoint), Error> {
    let remote_url = config
        .profile
        .upstream_nodes
        .clone()
        .unwrap()
        .into_iter()
        .next()
        .unwrap(); // upstream_node_url.clone();
    match make_client(Some(remote_url.clone()), waypoint) {
        Ok(client) => Ok((client, waypoint)),
        Err(e) => Err(e),
    }
}

/// get client type with defaults from toml for local node
pub fn default_local_client(
    config: &AppCfg,
    waypoint: Waypoint,
) -> Result<(LibraClient, Waypoint), Error> {
    let local_url = config
        .profile
        .default_node
        .clone()
        .expect("could not get url from configs");
    match make_client(Some(local_url.clone()), waypoint) {
        Ok(client) => Ok((client, waypoint)),
        Err(e) => Err(e),
    }
}

/// connect a swarm client
pub fn swarm_test_client(
    config: &mut AppCfg,
    swarm_path: PathBuf,
) -> Result<(LibraClient, Waypoint), Error> {
    let (url, waypoint) = ol_types::config::get_swarm_rpc_url(swarm_path.clone());
    config.profile.default_node = Some(url.clone());
    config.profile.upstream_nodes = Some(vec![url.clone()]);

    match make_client(Some(url.clone()), waypoint) {
        Ok(client) => Ok((client, waypoint)),
        Err(e) => Err(e),
    }
}

/// picks what URL to connect to based on sync state. Or returns the client for swarm.
pub fn pick_client(
    swarm_path: Option<PathBuf>,
    config: &mut AppCfg,
) -> Result<(LibraClient, Waypoint), Error> {
    let is_swarm = *&swarm_path.is_some();
    if let Some(path) = swarm_path {
        return swarm_test_client(config, path);
    };
    let waypoint = config
        .get_waypoint(swarm_path)?;
    // check if is in sync
    let local_client = default_local_client(config, waypoint.clone())?;
    
    let mut node = Node::new(local_client.0, config.clone(), is_swarm);
    if let Ok(s) = node.check_sync() {
        if s.is_synced {
            return Ok((node.client, waypoint.clone()))
        }
    }
    default_remote_client(config, waypoint.clone())
}
