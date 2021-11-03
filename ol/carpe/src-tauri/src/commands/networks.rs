//! networks to connect to

use std::fmt;

use diem_types::waypoint::Waypoint;
use url::Url;
use rand::seq::SliceRandom;
use crate::{carpe_error::CarpeError, configs::{self, set_waypoint_from_upstream}, seed_peers};

#[derive(serde::Deserialize, serde::Serialize, Debug)]
pub struct NetworkProfile {
  pub chain_id: String, // Todo, use the Network Enum
  pub url: Url,
  pub waypoint: Waypoint,
  pub profile: String, // tbd, to use default node, or to use upstream, or a custom url.
}

impl NetworkProfile {
  pub fn new() -> Result<Self, CarpeError> {
    let cfg = configs::get_cfg()?;
    if let Some(url) = cfg.profile.default_node {
      Ok(NetworkProfile {
        chain_id: cfg.chain_info.chain_id,
        url: url,
        waypoint: cfg.chain_info.base_waypoint.unwrap_or_default(),
        profile: "default".to_string(),
      })
    } else {
      Err(CarpeError::misc("could not retrive network profile"))
    }
  }
}

#[derive(serde::Deserialize, serde::Serialize, Debug)]
pub enum Networks {
  Mainnet,
  Rex,
  Custom,
}

impl fmt::Display for Networks {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
        // or, alternatively:
        // fmt::Debug::fmt(self, f)
    }
}


#[tauri::command]
pub fn toggle_network(network: Networks) -> Result<NetworkProfile, CarpeError> {
  dbg!("toggle network");
  let peers = match network {
    Networks::Mainnet => seed_peers::get_mainnet(),
    Networks::Rex => seed_peers::get_testnet(),
    Networks::Custom => todo!(),
  };

  let random = peers.choose(&mut rand::thread_rng()).unwrap().to_owned();

  configs::set_upstream_nodes(peers).map_err(|e|  {
    let err_msg = format!("could not set upstream nodes, message: {}", &e.to_string());
    CarpeError::misc(&err_msg)
  })?;

  configs::set_default_node(random).map_err(|e|  {
    let err_msg = format!("could not set default node, message: {}", &e.to_string());
    CarpeError::misc(&err_msg)
  })?;

  configs::set_chain_id(network.to_string()).map_err(|e|  {
    let err_msg = format!("could not set chain id, message: {}", &e.to_string());
    CarpeError::misc(&err_msg)
  })?;

  NetworkProfile::new()
}



#[tauri::command]
pub fn get_networks() -> Result<NetworkProfile, CarpeError> {
  NetworkProfile::new()
}

#[tauri::command]
pub fn update_upstream(url: Url, wp: Waypoint) -> Result<NetworkProfile, CarpeError> {
  configs::set_default_node(url).map_err(|e| CarpeError::misc(&e.to_string()))?;
  configs::set_waypoint(wp).map_err(|e| CarpeError::misc(&e.to_string()))?;
  NetworkProfile::new()
}


#[tauri::command]
pub fn refresh_waypoint() -> Result<NetworkProfile, CarpeError> {
  
  set_waypoint_from_upstream().map_err(|e|  {
    let err_msg = format!("could not get epoch data from upstream, message: {}", &e.to_string());
    CarpeError::misc(&err_msg)
  })?;
  NetworkProfile::new()
}

