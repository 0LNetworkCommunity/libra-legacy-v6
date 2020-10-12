//! `start` subcommand - example of how to write a subcommand

use crate::block::build_block;
use crate::config::MinerConfig;
use crate::prelude::*;
use std::path::PathBuf;

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
#[derive(Command, Debug, Options)]
pub struct GenesisCmd {
    // Option for setting path for the blocks/proofs that are mined.
    #[options(help = "The home directory where the blocks will be stored")]
    home: PathBuf, 
}

impl Runnable for GenesisCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();

        build_block::mine_genesis(&miner_configs);
    }
}

impl config::Override<MinerConfig> for GenesisCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
        Ok(config)
    }
}
