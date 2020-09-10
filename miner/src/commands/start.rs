//! `start` subcommand - example of how to write a subcommand

// use crate::block::Block;
use crate::block::*;
use crate::block::build_block::make_params;

use crate::config::OlMinerConfig;
use crate::prelude::*;
use anyhow::Error;
use libra_types::waypoint::Waypoint;
use crate::resubmit_tx::resubmit_backlog;
use std::path::PathBuf;

// use rustyline::error::ReadlineError;
// use rustyline::Editor;

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};

/// `start` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct StartCmd {
    // Option for --waypoint, to set a specific waypoint besides genesis_waypoint which is found in miner.toml
    #[options(help = "Provide a waypoint for tx submission. Will otherwise use what is in miner.toml")]
    waypoint: String,
    // Option for --resubmit, only sends backlogged transactions.
    #[options(help = "Start but don't mine, and only resubmit backlog of proofs")]
    resubmit: bool,
    // Oprtion for setting path for the blocks/proofs that are mined.
    #[options(help = "Provide a waypoint for the libra chain")]
    home: PathBuf, 
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();

        println!("Enter your 0L mnemonic:");
        let mnemonic_string = rpassword::read_password_from_tty(Some("\u{1F511}")).unwrap();

        let waypoint: Waypoint;
        let parsed_waypoint: Result<Waypoint, Error> = self.waypoint.parse();
        match parsed_waypoint {
            Ok(v) => {
                println!("Using Waypoint from CLI args:\n{}", v);
                waypoint = parsed_waypoint.unwrap();
            }
            Err(_e) => {
                println!("Info: No waypoint parsed from command line args. Received: {:?}\n\
                Using waypoint in miner.toml\n {:?}",
                self.waypoint,
                miner_configs.chain_info.base_waypoint);
                waypoint = miner_configs.chain_info.base_waypoint.parse().unwrap();

            }
        }

        if self.resubmit {
            let tx_params = make_params(&mnemonic_string, waypoint, &miner_configs);
            resubmit_backlog(self.home.to_owned(), &miner_configs, tx_params);

        } else {
            let result = build_block::mine_and_submit(&miner_configs, mnemonic_string, waypoint);
            match result {
                Ok(_val) => {}
                Err(err) => {
                    println!("Failed to mine_and_submit: {}", err);
                }
            }
        }
    }
}

impl config::Override<OlMinerConfig> for StartCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: OlMinerConfig) -> Result<OlMinerConfig, FrameworkError> {
        Ok(config)
    }
}
