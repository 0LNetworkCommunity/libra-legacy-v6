//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{application::app_config, config::MinerConfig, keygen};

use abscissa_core::{Command, Options, Runnable};
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

pub fn initialize_miner(authkey: AuthenticationKey, account: AccountAddress) {
    MinerConfig::init_miner_configs(authkey, account, None);
}

pub fn initialize_validator(wallet: &WalletLibrary) {
    let stored_configs = app_config();
    let home_dir = &stored_configs.workspace.node_home;
    let keys = KeyScheme::new(wallet); // TODO: Make it a reference
    init::key_store_init(home_dir, "test".to_owned(), keys);

    key::set_operator_key(home_dir);
}