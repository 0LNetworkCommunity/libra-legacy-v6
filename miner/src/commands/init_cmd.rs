//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{application::app_config, config::MinerConfig, keygen};

use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use libra_genesis_tool::{init, key, keyscheme::KeyScheme};
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey
};
use libra_wallet::WalletLibrary;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        let (authkey, account, _) = keygen::account_from_prompt();
        initialize_miner(authkey, account);
    }
}

pub fn initialize_miner(authkey: AuthenticationKey, account: AccountAddress) -> Result <MinerConfig, Error>{
    let miner_config = MinerConfig::init_miner_configs(authkey, account, None);
    Ok(miner_config)
}

pub fn initialize_validator(wallet: &WalletLibrary, miner_config: &MinerConfig) -> Result <(), Error>{
    // let stored_configs = app_config();
    let home_dir = &miner_config.workspace.node_home;
    let keys = KeyScheme::new(wallet); // TODO: Make it a reference
    let namespace = "test".to_owned();
    init::key_store_init(home_dir, &namespace, keys);

    key::set_operator_key(home_dir, &namespace);
    Ok(())
}