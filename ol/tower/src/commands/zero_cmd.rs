//! `start` subcommand - example of how to write a subcommand

use crate::{application::app_config, block::write_genesis};
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{Command, Options, Runnable};
use diem_global_constants::{VDF_SECURITY_PARAM, delay_difficulty};


#[derive(Command, Debug, Options)]
pub struct ZeroCmd {}

impl Runnable for ZeroCmd {
    /// Start the application.
    fn run(&self) {
        // Assumes the app has already been initialized.
        let miner_config = app_config().clone();

        let difficulty = delay_difficulty();
        let security = VDF_SECURITY_PARAM;
        write_genesis(&miner_config, difficulty, security);
    }
}