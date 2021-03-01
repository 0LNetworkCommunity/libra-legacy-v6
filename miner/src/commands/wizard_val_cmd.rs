//! `version` subcommand

#![allow(clippy::never_loop)]

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
    #[options(help = "run keygen before wizard")]
    keygen: bool,   
    #[options(help = "build genesis from ceremony repo")]
    rebuild_genesis: bool, 
    #[options(help = "skip mining a block zero")]
    skip_mining: bool,   
}

impl Runnable for ValWizardCmd {
    /// Print version message
    fn run(&self) {
        // Keygen
        if self.keygen {
            keygen_cmd::generate_keys();
            status_ok!("\nKeys generated OK", "\n...........................\n");
        }

        status_info!("\nValidator Config Wizard.", "Next you'll enter your mnemonic and some other info to configure your validator node and on-chain account. If you haven't yet generated keys you can re-run this command with the flag '--keygen', or run the standalone keygen subcommand with 'miner keygen'.\n\nYour first 0L proof-of-work will be mined now. Expect this to take up to 15 minutes on modern CPUs.\n");

        // Get credentials from prompt
        let (authkey, account, wallet) = keygen::account_from_prompt();

        // Initialize Miner
        // Need to assign miner_config, because reading from app_config can only be done at startup, and it will be blank at the time of wizard executing.
        let miner_config = init_cmd::initialize_miner(authkey, account).unwrap();
        status_ok!("\nMiner config OK", "\n...........................\n");

        // Initialize Validator Keys
        init_cmd::initialize_validator(&wallet, &miner_config).unwrap();
        status_ok!("\nKey file OK", "\n...........................\n");

        if !self.rebuild_genesis {
            genesis_cmd::get_files(
                miner_config.workspace.node_home.clone(),
                &self.github_org,
                &self.repo,
            );
            status_ok!("\nGenesis OK", "\n...........................\n");
        }

        // Build Genesis and node.yaml file
        genesis_cmd::genesis_files(
            &miner_config,
            &self.chain_id,
            &self.github_org,
            &self.repo,
            &self.rebuild_genesis,
        );
        status_ok!("\nNode config OK", "\n...........................\n");

        if !self.skip_mining {
            // Mine Block
            zero_cmd::mine_zero(&miner_config);
            status_ok!("\nProof OK", "\n...........................\n");
        }
        
        // Write Manifest
        manifest_cmd::write_manifest(None, wallet);
        status_ok!("\nAccount manifest OK", "\n...........................\n");

        status_info!("Your validator node and miner app are now configured.", "The account.json can be used to submit an account creation transaction on-chain. Someone with an existing account (with GAS) can do this for you.");
    }
}
