//! `version` subcommand

#![allow(clippy::never_loop)]

// use std::{path::PathBuf};
use crate::{application::app_config, config::OlCliConfig};
use abscissa_core::{Command, FrameworkError, Options, Runnable, config};
use anyhow::Error;
use libra_genesis_tool::{init, key, keyscheme::KeyScheme};
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey
};
use std::{path::PathBuf};
use libra_wallet::WalletLibrary;
use keygen;

/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    #[options(help = "home path for miner app")]
    path: Option<PathBuf>,
    #[options(help = "Skip miner app configs")]
    skip_miner: bool,
    #[options(help = "Skip validator init")]
    skip_val: bool,
}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        let (authkey, account, wallet) = keygen::account_from_prompt();
        let mut miner_config = app_config().to_owned();
        
        if !self.skip_miner { miner_config = initialize_miner(authkey, account, 
            &self.path).unwrap() };
        if !self.skip_val { initialize_validator(&wallet, &miner_config).unwrap() };
    }
}

pub fn initialize_miner(authkey: AuthenticationKey, account: AccountAddress, path: &Option<PathBuf>) -> Result <OlCliConfig, Error>{
    let miner_config = OlCliConfig::init_miner_configs(authkey, account, path);
    Ok(miner_config)
}

pub fn initialize_validator(wallet: &WalletLibrary, miner_config: &OlCliConfig) -> Result <(), Error>{
    let home_dir = &miner_config.workspace.node_home;
    let keys = KeyScheme::new(wallet);
    let namespace = miner_config.profile.auth_key.to_owned();
    init::key_store_init(home_dir, &namespace, keys, false);
    key::set_operator_key(home_dir, &namespace);
    key::set_owner_key(home_dir, &namespace);

    Ok(())
}

impl config::Override<OlCliConfig> for InitCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: OlCliConfig) -> Result<OlCliConfig, FrameworkError> {
        Ok(config)
    }
}