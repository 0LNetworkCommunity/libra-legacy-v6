//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::keygen;

use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use std::{path::PathBuf};
use super::{init_cmd, keygen_cmd, manifest_cmd, zero_cmd};

/// `val-wizard` subcommand
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
        validator().unwrap();
    }
}

pub fn validator() -> Result<(), Error> {
    // Keygen
    keygen_cmd::generate_keys();
    println!("......... Keys generated");

    // Get credentials from prompt
    let (authkey, account, wallet) = keygen::account_from_prompt();

    // Initialize Miner
    // Need to assign miner_config, because reading from app_config can only be done at startup, and it will be blank at the time of wizard executing.
    let miner_config = init_cmd::initialize_miner(authkey, account)?;
    println!("......... App configs Saved");
    // let secs = time::Duration::from_secs(10);
    // thread::sleep(secs);


    // Initialize Validator Keys
    init_cmd::initialize_validator(&wallet, &miner_config)?;
    println!("......... Validator Key File saved");

    // Create Node Yaml

    //Create Genesis
    

    // Mine Block
    zero_cmd::mine_zero(&miner_config);
    println!("......... Proof Mined");

    // Write Manifest
    manifest_cmd::write_manifest(None, wallet);
    println!("......... Account Manifest Saved");

    Ok(())

}