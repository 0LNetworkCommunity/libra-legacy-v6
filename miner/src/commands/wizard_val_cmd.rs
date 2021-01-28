//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::keygen;

use abscissa_core::{Command, Options, Runnable};
use std::{path::PathBuf};

use super::{init_cmd, keygen_cmd, manifest_cmd, zero_cmd};


/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValWizardCmd {
    #[options(help = "path to write account manifest")]
    path: Option<PathBuf>,
    // #[options(help = "path to file to be checked")]
    // check: bool,
    // #[options(help = "regenerates account manifest from mnemonic")]
    // fix: bool,
    // #[options(help = "creates a validator account")]
    // validator: bool,
    // #[options(help = "use an existing block_0.json file and skip mining")]
    // block_zero: Option<PathBuf>,
}

impl Runnable for ValWizardCmd {
    /// Print version message
    fn run(&self) {
        validator();
    }
}

pub fn validator() {
    // Keygen
    keygen_cmd::generate_keys();
    
    let (authkey, account, wallet) = keygen::account_from_prompt();

    // Initialize Miner
    init_cmd::initialize_miner(authkey, account);

    // Initialize Validator


    // Mine Block
    zero_cmd::mine_zero();
    // Write Manifest
    manifest_cmd::write_manifest(None, wallet);
}