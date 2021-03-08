//! `bal` subcommand

use cli::libra_client::LibraClient;
use reqwest::Url;
use libra_types::{waypoint::Waypoint};
use anyhow::Error;
use anyhow::{Result};

/// returns a LibraClient instance.
// TODO: Use app config file for params
pub fn make_client(url: Option<Url>, waypoint: Waypoint) -> Result<LibraClient, Error> {
    Ok(LibraClient::new(
        url.clone().unwrap_or("http://localhost:8080".to_owned().parse().unwrap()),
        waypoint
    ).unwrap())
}
