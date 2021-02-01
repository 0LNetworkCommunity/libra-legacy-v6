//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::keygen;

use abscissa_core::{Command, Options, Runnable, status_info, status_ok};
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
    #[options(help = "skip the keygen if you have keys")]
    skip_keys: bool,   
}

impl Runnable for ValWizardCmd {
    /// Print version message
    fn run(&self) {
        // Keygen
        if !self.skip_keys {
            keygen_cmd::generate_keys();
            status_ok!("\nKeys generated OK", "\n...........................\n");
        }

        println!("Next you'll need to enter your mnemonic and some other info to configure your validator node and on-chain account.\n\n");

        // Get credentials from prompt
        let (authkey, account, wallet) = keygen::account_from_prompt();

        // Initialize Miner
        // Need to assign miner_config, because reading from app_config can only be done at startup, and it will be blank at the time of wizard executing.
        let miner_config = init_cmd::initialize_miner(authkey, account).unwrap();
        status_ok!("\nMiner config OK", "\n...........................\n");

        // Initialize Validator Keys
        init_cmd::initialize_validator(&wallet, &miner_config).unwrap();
        status_ok!("\nKey file OK", "\n...........................\n");

        genesis_cmd::get_files(miner_config.workspace.node_home.clone());
        status_ok!("\nGenesis OK", "\n...........................\n");

        // Build Genesis and node.yaml file
        genesis_cmd::create_node_files(
            &miner_config,
            self.chain_id.unwrap_or(1),
            &self.github_org.clone().unwrap_or("OLSF".to_string()),
            &self.repo.clone().unwrap_or("genesis-archive".to_string()),
        );
        status_ok!("\nNode config OK", "\n...........................\n");

        // Mine Block
        zero_cmd::mine_zero(&miner_config);
        status_ok!("\nProof OK", "\n...........................\n");

        // Write Manifest
        manifest_cmd::write_manifest(None, wallet);
        status_ok!("\nAccount manifest OK", "\n...........................\n");

        status_info!("Your validator node and miner app are now configured.", "You can now use the account.json file to submit the account creation transaction.");
    }
}
