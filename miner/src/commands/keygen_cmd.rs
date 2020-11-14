//! `submit` subcommand

#![allow(clippy::never_loop)]
use abscissa_core::{Command, Options, Runnable};
use libra_wallet::WalletLibrary;
use crate::{node_keys::KeyScheme, config};
use crate::commands::CONFIG_FILE;
use crate::keygen::keygen;
use libra_global_constants::NODE_HOME;
use toml;
use std::{net::Ipv4Addr, fs, io::Write};
use rustyline::Editor;
use config::MinerConfig;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {}

impl Runnable for KeygenCmd {
    /// Print version message
    fn run(&self) {
        let mut miner_configs = config::MinerConfig::default();

        keygen(&mut miner_configs);

    }
}
