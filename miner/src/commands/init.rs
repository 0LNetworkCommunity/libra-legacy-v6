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
        println!("Enter your 0L mnemonic:");
        let mnemonic_string = rpassword::read_password_from_tty(Some("\u{1F511} ")).unwrap();
        let (authkey, account, _) = keygen::get_account_from_mnem(mnemonic_string);
        MinerConfig::init_miner_configs(authkey, account);
    }
}
