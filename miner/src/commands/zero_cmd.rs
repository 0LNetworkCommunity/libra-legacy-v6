//! `start` subcommand - example of how to write a subcommand

use crate::{application::app_config, block::build_block};
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{Command, Options, Runnable};


#[derive(Command, Debug, Options)]
pub struct ZeroCmd {}

impl Runnable for ZeroCmd {
    /// Start the application.
    fn run(&self) {
        mine_zero();
    }
}

pub fn mine_zero() {
    let saved_configs = app_config();
    build_block::write_genesis(&saved_configs);
}