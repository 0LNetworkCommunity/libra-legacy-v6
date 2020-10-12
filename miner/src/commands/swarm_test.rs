//! `start` subcommand - example of how to write a subcommand

// use crate::block::Block;

use crate::config::MinerConfig;
use crate::prelude::*;
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use crate::test_tx_swarm::test_runner;
use std::path::PathBuf;


/// `start` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct SwarmCmd {
    #[options(help = "Provide a waypoint for the libra chain")]
    waypoint: String, //Option<Waypoint>,

    #[options(help = "Provide a waypoint for the libra chain")]
    home: PathBuf, 
}

impl Runnable for SwarmCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();

        println!("Testing Submit to Swarm. Using swarm private key");

        let result = test_runner(self.home.to_owned(), &miner_configs, false);
        println!("Executing Result: {:?}", result);
    }
}

impl config::Override<MinerConfig> for SwarmCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
        Ok(config)
    }
}
