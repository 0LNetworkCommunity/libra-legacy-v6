//! `start` subcommand - example of how to write a subcommand

use crate::{
    backlog,
    block::*,
    submit_tx::{get_params, get_oper_params},
};
use libra_genesis_tool::keyscheme::KeyScheme;
use reqwest::Url;

use crate::config::MinerConfig;
use crate::prelude::*;
use anyhow::Error;
use libra_types::waypoint::Waypoint;
use std::path::PathBuf;

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
    // Option for --waypoint, to set a specific waypoint besides genesis_waypoint which is found in key_store.json
    #[options(help = "Provide a waypoint for tx submission. Will otherwise use what is in key_store.json")]
    waypoint: String,
    
    // Option for --backlog, only sends backlogged transactions.
    #[options(help = "Start but don't mine, and only resubmit backlog of proofs")]
    backlog_only: bool,

    // don't process backlog
    #[options(help = "Skip backlog")]
    skip: bool,

    // Option for setting path for the blocks/proofs that are mined.
    #[options(help = "The home directory where the blocks will be stored")]
    home: PathBuf, 

    // Option for overriding url to connect
    #[options(help = "Option for overriding url to connect")]
    url: Option<Url>, 

    // Option for overriding url to connect
    #[options(help = "Connect to backup node, instead of default (local) node")]
    backup_url: bool, 

    // Option for operator to submit transactions for owner.
    #[options(help = "Operator will submit transactions for owner")]
    is_operator: bool, 
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();
        let waypoint: Waypoint;
        let parsed_waypoint: Result<Waypoint, Error> = self.waypoint.parse();
        match parsed_waypoint {
            Ok(from_cli) => {
                println!("Using Waypoint from CLI args:\n{}", from_cli);
                waypoint = from_cli;
            }
            Err(_e) => {
                status_info!("Waypoint:",format!("No waypoint parsed from command line args. Searching for waypoint in key_store.json"));
                match miner_configs.get_waypoint() {
                    Some(from_ks) => { 
                        status_ok!("Waypoint:", "found in key_store.json");
                        waypoint = from_ks 
                    }
                    None => {
                       status_info!("Waypoint:", format!("Not found in key_store.json. Failover to chain_info.base_waypoint in miner.toml"));

                       match miner_configs.chain_info.base_waypoint {
                           Some(from_toml) => {
                                status_ok!("Waypoint:", "found in miner.toml");
                                waypoint = from_toml
                            }
                           None => {
                               status_err!("No waypoint found in commandline, key_store.json, nor miner.toml. Exiting.");
                               std::process::exit(-1);
                           }
                       }
                    }
                }
            }
        }

        let tx_params = if self.is_operator {
            get_oper_params(waypoint, &miner_configs, self.url.clone(), self.backup_url)
        } else {
            // prompt the owner for account
            let (_authkey, _account, wallet) = keygen::account_from_prompt();
            let keys = KeyScheme::new(&wallet);
            get_params(keys, waypoint, &miner_configs, self.url.clone(), self.backup_url)
        };
        
        // Check for, and submit backlog proofs.
        if !self.skip {
            backlog::process_backlog(&miner_configs, &tx_params, self.is_operator);
        }

        if !self.backlog_only {
            // Steady state.
            let result = build_block::mine_and_submit(
                &miner_configs,
                tx_params,
                self.is_operator
            );
            match result {
                Ok(_val) => {}
                Err(err) => {
                    println!("Failed to mine_and_submit: {}", err);
                }
            }
        }
    }
}

impl config::Override<MinerConfig> for StartCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
        Ok(config)
    }
}
