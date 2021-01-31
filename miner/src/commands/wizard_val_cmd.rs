//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::keygen;

use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use std::{path::PathBuf};
use super::{genesis_cmd, init_cmd, keygen_cmd, manifest_cmd, zero_cmd};

/// `val-wizard` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValWizardCmd {
    #[options(help = "path to write account manifest")]
    path: Option<PathBuf>,
    #[options(help = "id of the chain")]
    chain_id: Option<u8>,
    #[options(help = "github org of genesis repo")]
    github_org: Option<String>,
    #[options(help = "repo with with genesis transactions")]
    repo: Option<String>,   
}

impl Runnable for ValWizardCmd {
    /// Print version message
    fn run(&self) {
        validator(
            self.chain_id.unwrap_or_else(||{1}),
            &self.github_org.clone().unwrap_or("OLSF".to_string()),
            &self.repo.clone().unwrap_or("experimental-genesis".to_string())
        ).unwrap();
    }
}

pub fn validator(chain_id: u8, github_org: &str, repo: &str) -> Result<(), Error> {
    // Keygen
    keygen_cmd::generate_keys();
    println!("......... Keys generated");

    // Get credentials from prompt
    let (authkey, account, wallet) = keygen::account_from_prompt();

    // Initialize Miner
    // Need to assign miner_config, because reading from app_config can only be done at startup, and it will be blank at the time of wizard executing.
    let miner_config = init_cmd::initialize_miner(authkey, account)?;
    println!("......... App configs Saved");

    // Initialize Validator Keys
    init_cmd::initialize_validator(&wallet, &miner_config)?;
    println!("......... Validator Key File saved");

    // Build Genesis and node.yaml file
    genesis_cmd::create_node_files(
        &miner_config,
        chain_id,
        github_org,
        repo,
    );
    println!("......... Genesis file created");

    // Mine Block
    zero_cmd::mine_zero(&miner_config);
    println!("......... Proof Mined");

    // Write Manifest
    manifest_cmd::write_manifest(None, wallet);
    println!("......... Account Manifest Saved");

    Ok(())
}