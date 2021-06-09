//! `bal` subcommand

use crate::{config::AppCfg, entrypoint, node::node::Node, prelude::app_config};
use anyhow::Error;
use anyhow::Result;
use cli::diem_client::DiemClient;
use diem_types::waypoint::Waypoint;
use reqwest::Url;
use std::path::PathBuf;

/// returns a DiemClient instance.
// TODO: Use app config file for params
pub fn make_client(url: Option<Url>, waypoint: Waypoint) -> Result<DiemClient, Error> {
    match url {
        Some(u) => DiemClient::new(u, waypoint),
        None => DiemClient::new(
            Url::parse("http://localhost:8080").expect("Couldn't create diem client"),
            waypoint,
        ),
    }
}

/// Experimental
pub fn get_client() -> Option<DiemClient> {
    let entry_args = entrypoint::get_args();
    // if url and waypoint provided as fn params
    //     return DiemClient::new(url, waypoint);

    // if local node in-sync
    //    return default_local_client()
    // else find and return connect-able upstream node
    let config = app_config();
    let waypoint = config
        .get_waypoint(entry_args.swarm_path)
        .expect("could not get waypoint");
    for url in config.profile.upstream_nodes.as_ref().unwrap() {
        let client = DiemClient::new(url.clone(), waypoint).unwrap();
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
) -> Option<(DiemClient, Waypoint)> {
    let remote_url = config
        .profile
        .upstream_nodes
        .clone()
        .unwrap()
        .into_iter()
        .next()
        .unwrap(); // upstream_node_url.clone();
    match make_client(Some(remote_url.clone()), waypoint) {
        Ok(client) => Some((client, waypoint)),
        Err(_) => None,
    }
}

/// get client type with defaults from toml for local node
pub fn default_local_client(
    config: &AppCfg,
    waypoint: Waypoint,
) -> Option<(DiemClient, Waypoint)> {
    let local_url = config
        .profile
        .default_node
        .clone()
        .expect("could not get url from configs");
    match make_client(Some(local_url.clone()), waypoint) {
        Ok(client) => Some((client, waypoint)),
        Err(_) => None,
    }
}

/// connect a swarm client
pub fn swarm_test_client(
    config: &mut AppCfg,
    swarm_path: PathBuf,
) -> Option<(DiemClient, Waypoint)> {
    let (url, waypoint) = ol_types::config::get_swarm_configs(swarm_path.clone());
    config.profile.default_node = Some(url.clone());
    config.profile.upstream_nodes = Some(vec![url.clone()]);

    match make_client(Some(url.clone()), waypoint) {
        Ok(client) => Some((client, waypoint)),
        Err(_e) => None,
    }
}

/// picks what URL to connect to based on sync state. Or returns the client for swarm.
pub fn pick_client(
    swarm_path: Option<PathBuf>,
    config: &mut AppCfg,
) -> Option<(DiemClient, Waypoint)> {
    if let Some(path) = swarm_path {
        return swarm_test_client(config, path);
    };
    let waypoint = config
        .get_waypoint(swarm_path)
        .expect("could not get waypoint");
    // check if is in sync
    if let Ok(s) = Node::check_sync(config, waypoint) {
        if s.is_synced {
            return default_local_client(config, waypoint.clone());
        }
    }
    default_remote_client(config, waypoint.clone())
}
