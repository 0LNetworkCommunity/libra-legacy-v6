//! `start` subcommand - example of how to write a subcommand

use crate::{application::app_config, block::build_block, config::MinerConfig};
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{Command, Options, Runnable};


#[derive(Command, Debug, Options)]
pub struct ZeroCmd {}

impl Runnable for ZeroCmd {
    /// Start the application.
    fn run(&self) {
        // Assumes the app has already been initialized.
        let saved_configs = app_config();
        mine_zero(&saved_configs);
    }
}

pub fn mine_zero(miner_config: &MinerConfig) {
    // let saved_configs = app_config();
    // dbg!(&saved_configs.profile.auth_key);
    build_block::write_genesis(&miner_config);
}