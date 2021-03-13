//! `bal` subcommand

use cli::libra_client::LibraClient;
use reqwest::Url;
use libra_types::{waypoint::Waypoint};
use anyhow::Error;
use anyhow::{Result};
use crate::prelude::app_config;

/// returns a LibraClient instance.
// TODO: Use app config file for params
pub fn make_client(url: Option<Url>, waypoint: Waypoint) -> Result<LibraClient, Error> { 
    Ok(LibraClient::new(
        url.clone().unwrap_or("http://localhost:8080".to_owned().parse().unwrap()),
        waypoint
    ).unwrap())
}

/// get client type with defaults from toml for remote node
pub fn default_remote_client()  ->(Result<LibraClient, Error>, Url){
    let config = app_config();
    let remote_url = config.upstream_node_url.clone();
    let waypoint = config.base_waypoint.clone();
    (make_client(Some(remote_url.clone()), waypoint), remote_url)
}

/// get client type with defaults from toml for local node
pub fn default_local_client()  -> (Result<LibraClient, Error>, Url){
    let config = app_config();
    let local_url = config.upstream_node_url.clone();
    let waypoint = config.base_waypoint.clone();
    (make_client(Some(local_url.clone()), waypoint), local_url)
}