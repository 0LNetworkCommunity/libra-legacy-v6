//! 0L configs file

use std::{fs, path::PathBuf};

use anyhow::{Error, bail};
use cli::diem_client::DiemClient;
use diem_types::{transaction::authenticator::AuthenticationKey, waypoint::Waypoint};
use dirs;
use ol::{
  config::AppCfg,
  node::{client, node::Node},
};
use diem_types::account_address::AccountAddress;

use ol_types::config::{self, TxType, bootstrap_waypoint_from_upstream};
use txs::submit_tx::{TxParams, get_tx_params_from_keypair};
use url::Url;

use crate::{carpe_error::CarpeError, key_manager};

static ACCOUNTS_DB_FILE: &str = "accounts.json";
static APP_CONFIG_FILE: &str = "0L.toml";

// get the config path for files
pub fn default_config_path() -> PathBuf {
  dirs::home_dir().unwrap().join(".0L").join(APP_CONFIG_FILE)
}

pub fn default_accounts_db_path() -> PathBuf {
  dirs::home_dir().unwrap().join(".0L").join(ACCOUNTS_DB_FILE)
}

/// Get all the 0L configs. For tx sending and upstream nodes
pub fn get_cfg() -> Result<AppCfg, Error> {
  let config_toml = default_config_path();
  dbg!(&config_toml);
  Ok(config::parse_toml(config_toml.to_str().unwrap().to_string())?)
}

/// get transaction parameters from config file
pub fn get_tx_params(url: Option<&str>, ) -> Result<TxParams, anyhow::Error> { // TODO: Should the Error type be a CarpeError?
  let mut config = get_cfg()?;
  if let Some(s) = url {
    match s.parse::<Url>() {
        Ok(u) => config.profile.default_node = Some(u),
        Err(_) => {},
    }
  }
  // Requires user input to get OS keyring
  let keypair = key_manager::get_keypair(&config.profile.account.to_string())?;
  get_tx_params_from_keypair(
    config.clone(),
    TxType::Miner,
    keypair,
    None,
    false,
    false,
  )
}



pub fn get_node_obj() -> Result<Node, CarpeError> {
  let cfg = get_cfg()?;
  let client = get_diem_client(&cfg)?;

  Ok(Node::new(client, &cfg, false))
}

pub fn get_diem_client(cfg: &AppCfg) -> Result<DiemClient, CarpeError> {

  DiemClient::new(
    cfg.clone().profile.default_node.ok_or(CarpeError::misc("could not load default_node"))?, 
    cfg.clone().chain_info.base_waypoint.ok_or(CarpeError::misc("could not load base_waypoint"))?
  )
  .map_err(|_|{ CarpeError::misc("could not load tx params") })
}

/// Get all the 0L configs. For tx sending and upstream nodes
pub fn set_default_node(url: Url) -> Result<AppCfg, Error> {
  let mut cfg = get_cfg()?;
  cfg.profile.default_node = Some(url);
  cfg.save_file();
  Ok(cfg)
}

/// Get all the 0L configs. For tx sending and upstream nodes
pub fn set_chain_id(chain_id: String) -> Result<AppCfg, Error> {
  let mut cfg = get_cfg()?;
  cfg.chain_info.chain_id = chain_id;
  cfg.save_file();
  Ok(cfg)
}

/// Set the list of upstream nodes
pub fn set_upstream_nodes(vec_url: Vec<Url>) -> Result<AppCfg, Error> {
  let mut cfg = get_cfg()?;
  cfg.profile.upstream_nodes = Some(vec_url);
  cfg.save_file();
  Ok(cfg)
}






/// Get all the 0L configs. For tx sending and upstream nodes
pub fn set_waypoint(wp: Waypoint) -> Result<AppCfg, Error>  {
  let mut cfg = get_cfg()?;
  cfg.chain_info.base_waypoint = Some(wp);
  cfg.save_file();
  Ok(cfg)
}

/// Refresh the upstream peers in config, from chain data.
pub fn set_refresh_upstream(wp: Waypoint) -> Result<AppCfg, Error>  {
  let mut cfg = get_cfg()?;
  cfg.chain_info.base_waypoint = Some(wp);
  cfg.save_file();
  Ok(cfg)
}

/// Refresh the upstream peers in config, from chain data.
pub fn set_waypoint_from_upstream() -> Result<AppCfg, Error>  {
  let cfg = get_cfg()?;
  if let Some(mut json_rpc_node) = cfg.profile.default_node.clone() {
    let (_, wp) = bootstrap_waypoint_from_upstream(&mut json_rpc_node)?;
    set_waypoint(wp)
  } else {
    bail!("could not find default_node in 0L.toml")
  }

}

/// For devs, get the source path, needed to initialize swarm
pub fn dev_get_source_path() -> Result<Option<PathBuf>, Error> {
  let c = get_cfg()?;
  Ok(c.workspace.source_path)
}

/// Where the swarm_temp folder is created, defaults to .0L/swarm_temp
pub fn dev_get_swarm_temp() -> Result<PathBuf, Error> {
  Ok(get_cfg()?.workspace.node_home.join("swarm_temp"))
}


pub fn is_initialized() -> bool {
  default_config_path().exists()
}

// TODO: replace this wrappet
/// initialize default configs.
pub fn maybe_init_configs(account: AccountAddress, authkey: AuthenticationKey ) -> Result<(), Error>{
  set_account_profile(account, authkey)?;
  Ok(())
}

/// For switching between profiles in the Account DB.
pub fn set_account_profile(account: AccountAddress, authkey: AuthenticationKey) -> Result<AppCfg, Error> {
  dbg!(&is_initialized());
  let mut cfg = match is_initialized() {
    true => get_cfg()?,
    false => AppCfg::default(),
  };
  let vdf_dir_name = format!("vdf_proofs_{}", &account.to_string());

  cfg.workspace.node_home = default_config_path().parent().unwrap().to_owned();
  cfg.profile.account = account;
  cfg.profile.auth_key = authkey;

  cfg.workspace.block_dir = vdf_dir_name.clone(); 
  let vdf_path = cfg.workspace.node_home.join(&cfg.workspace.block_dir);

  if !cfg.workspace.node_home.exists() {
    fs::create_dir_all(&cfg.workspace.node_home)?;
  }
  if !vdf_path.exists() {
    fs::create_dir_all(&vdf_path)?;
  }

  cfg.save_file();
  Ok(cfg)
}

/// Todo: is this ever needed if maybe_init_configs always creates the file?
// fn set_vdf_dir(account: AccountAddress) -> Result<(), Error> {
//   let mut cfg = get_cfg();
//   let dir_name = format!("vdf_proofs_{}", account.to_string());
//   cfg.workspace.block_dir = dir_name.clone(); 
//   let path = cfg.workspace.node_home.join(&dir_name);
//   if (!path.exists()) {
//     match fs::create_dir_all(path) {
//         Ok(_) => {},
//         Err(e) => bail!("cannot create directory, message: {:?}", e.to_string()),
//     }
//   }
//   cfg.save_file();
//   Ok(())
// }

// TODO:
/// fetch upstream peers.
pub fn refresh_upstream_peers() -> Result<(), Error> {
  let mut cfg = get_cfg()?;
  let client = match client::pick_client(None, &mut cfg) {
    Ok(c) => c,
    Err(e) => {
      println!(
        "ERROR: Could not create a client to connect to network, exiting. Message: {:?}",
        e
      );
      bail!("cannot connect to a client");
      // exit(1);
    }
  };

  let mut node = Node::new(client, &cfg, false);

  let path = default_config_path();
  node.refresh_peers_update_toml(path)
}
