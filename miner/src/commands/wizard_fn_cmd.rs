//! `version` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable, status_info, status_ok};
use std::{path::PathBuf};
use super::{genesis_cmd};

/// `val-wizard` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct FnWizardCmd {
    #[options(help = "home path for all 0L files")]
    path: Option<PathBuf>,
    #[options(help = "id of the chain")]
    chain_id: Option<u8>,
    #[options(help = "github org of genesis repo")]
    github_org: Option<String>,
    #[options(help = "repo with with genesis transactions")]
    repo: Option<String>,   
    #[options(help = "build genesis from ceremony repo")]
    rebuild_genesis: bool,
    #[options(help = "skip fetching genesis blob")]
    skip_fetch_genesis: bool, 
}

impl Runnable for FnWizardCmd {
    /// Print version message
    fn run(&self) {

        status_info!("\nFullnode Config Wizard", "This tool will create a node.yaml file which is needed for the node to initialize and begin syncing. Different than validator configuration, no credentials are needed to operate a public fullnode.\n");

        if !self.skip_fetch_genesis {
            genesis_cmd::get_files(
                self.path.clone().unwrap_or(PathBuf::from(".")),
                &self.github_org,
                &self.repo,
            );
            status_ok!("\nGenesis OK", "\n...........................\n");
        }

        // Build Genesis and node.yaml file
        genesis_cmd::genesis_files(
            self.path.clone().unwrap_or(PathBuf::from(".")),
            Some("fullnode".to_string()),
            &self.chain_id,
            &self.github_org,
            &self.repo,
            &self.rebuild_genesis,
            &true,
        );
        status_ok!("\nNode config OK", "\n...........................\n");
    }
}
