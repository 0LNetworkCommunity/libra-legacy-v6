//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{block::build_block, config, keygen};
use abscissa_core::{Command, Options, Runnable};

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateCmd {
    #[options(help = "don't generate keys")]
    skip_keys: bool,
    #[options(help = "don't generate keys")]
    user: bool,
    #[options(help = "don't generate keys")]
    val: bool,
}


impl Runnable for CreateCmd {
    /// Print version message
    fn run(&self) {
        let mut miner_configs = config::MinerConfig::default();
        let (authkey, account) = keygen::keygen();
        miner_configs.profile.auth_key = authkey.to_string();
        miner_configs.profile.account = account;
        let block = build_block::mine_genesis(&miner_configs);
    }
}
