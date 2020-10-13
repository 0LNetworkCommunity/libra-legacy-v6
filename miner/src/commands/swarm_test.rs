//! `start` subcommand - example of how to write a subcommand

// use crate::block::Block;

use crate::{config::MinerConfig, test_tx_swarm::val_init_test};
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
    #[options(help = "Test the onboading transaction.")]
    init: bool,
    #[options(help = "The home directory where the blocks will be stored")]
    home: PathBuf, 
}

impl Runnable for SwarmCmd {
    /// Start the application.
    fn run(&self) {
        println!("Testing Submit tx to Swarm. Using swarm private key");

        if self.init {
            val_init_test(self.home.to_owned());
        } else {
            test_runner(self.home.to_owned());
        }
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
