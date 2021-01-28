//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{
    account,
    block::{build_block},
    config::MinerConfig,
    delay,
    keygen,
    node_keys::KeyScheme
};
use abscissa_core::{Command, Options, Runnable};
use std::{path::PathBuf};
use crate::prelude::app_config;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateCmd {
    #[options(help = "path to write account manifest")]
    path: Option<PathBuf>,
    #[options(help = "path to file to be checked")]
    check: bool,
    #[options(help = "regenerates account manifest from mnemonic")]
    fix: bool,
    #[options(help = "creates a validator account")]
    validator: bool,
    #[options(help = "use an existing block_0.json file and skip mining")]
    block_zero: Option<PathBuf>,
}

impl Runnable for CreateCmd {
    /// Print version message
    fn run(&self) {
        // let miner_configs = app_config();
        let path = self.path.clone().unwrap_or_else(|| PathBuf::from("."));
        if self.check {
            check(path);
        } else {
            let (_, _, wallet) = keygen::account_from_prompt();

            write_manifest(path, wallet);
        }
    }
}

fn write_manifest(path: PathBuf, wallet: WalletLibrary ) {
    let stored_configs = app_config();

    let keys = KeyScheme::new(wallet);

    let block = build_block::parse_block_file(block_path.to_owned());

    account::ValConfigs::new(
        block,
        keys,  
        miner_configs.profile.ip.to_string()
    ).create_manifest(path);
}

/// Checks the format of the account manifest, including vdf proof
fn check(path: PathBuf) {
    let user_data = account::UserConfigs::get_init_data(&path).expect(&format!("could not parse manifest in {:?}", &path));

    match delay::verify(&user_data.block_zero.preimage, &user_data.block_zero.proof) {
        true => println!("Proof verified in {:?}", &path),
        false => println!("Invalid proof in {:?}", &path)
    }
}
