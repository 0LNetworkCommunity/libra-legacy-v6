//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{config::MinerConfig, keygen};

use abscissa_core::{Command, Options, Runnable};
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey
};

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
    MinerConfig::init_miner_configs(authkey, account);
}