//! `init` subcommand

#![allow(clippy::never_loop)]

use crate::{application::app_config, config::AppCfg, entrypoint, migrate};
use abscissa_core::{Command, FrameworkError, Options, Runnable, config};
use anyhow::Error;
use libra_genesis_tool::{init, key};
use ol_keys::{scheme::KeyScheme, wallet};
use libra_json_rpc_client::AccountAddress;
use libra_types::transaction::authenticator::AuthenticationKey;
use std::{fs, path::PathBuf};
use libra_wallet::WalletLibrary;
use url::Url;
/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    #[options(help = "home path for miner app")]
    path: Option<PathBuf>,
    #[options(help = "An upstream peer to use in 0L.toml")]
    upstream_peer: Option<Url>,
    #[options(help = "Skip miner app configs")]
    skip_miner: bool,
    #[options(help = "Skip validator init")]
    skip_val: bool,
    #[options(help = "Fix config file, and migrate any missing fields")]
    fix: bool,
}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        if *&self.fix {
          migrate::migrate(self.path.to_owned());
          return
        };

        let entry_args = entrypoint::get_args();
        if let Some(path) = entry_args.swarm_path {
          let swarm_node_home = entrypoint::get_node_home();
          let absolute = fs::canonicalize(path).unwrap();
          initialize_host_swarm(absolute, swarm_node_home).unwrap();
          return
        }
        
        let (authkey, account, wallet) = wallet::get_account_from_prompt();
        // start with a default value, or read from file if already initialized
        let mut miner_config = app_config().to_owned();
        if !self.skip_miner { 
          miner_config =  initialize_host(
            authkey,
            account, 
            &self.upstream_peer,
            &self.path
          ).unwrap()
        };
        if !self.skip_val { initialize_validator(&wallet, &miner_config).unwrap() };
    }
}

/// Initializes the necessary 0L config files: 0L.toml
pub fn initialize_host(authkey: AuthenticationKey, account: AccountAddress, upstream_peer: &Option<Url>, path: &Option<PathBuf>) -> Result <AppCfg, Error>{
    let cfg = AppCfg::init_app_configs(authkey, account, upstream_peer, path);
    Ok(cfg)
}

/// Initializes the necessary 0L config files: 0L.toml
pub fn initialize_host_swarm(swarm_path: PathBuf, node_home: PathBuf) -> Result <AppCfg, Error>{
    let cfg = AppCfg::init_app_configs_swarm(swarm_path, node_home);
    Ok(cfg)
}
/// Initializes the necessary validator config files: genesis.blob, key_store.json
pub fn initialize_validator(wallet: &WalletLibrary, miner_config: &AppCfg) -> Result <(), Error>{
    let home_dir = &miner_config.workspace.node_home;
    let keys = KeyScheme::new(wallet);
    let namespace = miner_config.profile.auth_key.to_owned();
    init::key_store_init(home_dir, &namespace, keys, false);
    key::set_operator_key(home_dir, &namespace);
    key::set_owner_key(home_dir, &namespace);

    Ok(())
}

impl config::Override<AppCfg> for InitCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: AppCfg) -> Result<AppCfg, FrameworkError> {
        Ok(config)
    }
}