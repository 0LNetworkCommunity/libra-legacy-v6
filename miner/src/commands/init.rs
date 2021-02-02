//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{config::MinerConfig, keygen};

use abscissa_core::{Command, Options, Runnable};

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        let (authkey, account, _) = keygen::account_from_prompt();
        MinerConfig::init_miner_configs(authkey, account);
    }
}
