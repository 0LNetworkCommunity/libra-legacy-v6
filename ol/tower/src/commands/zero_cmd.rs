//! `start` subcommand - example of how to write a subcommand

use crate::{application::app_config, proof::write_genesis};
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{Command, Options, Runnable};

#[derive(Command, Debug, Options)]
pub struct ZeroCmd {}

impl Runnable for ZeroCmd {
    /// Start the application.
    fn run(&self) {
        // Assumes the app has already been initialized.
        let miner_config = app_config().clone();
        match write_genesis(&miner_config) {
            Ok(_) => println!("Success. Proof zero mined"),
            Err(e) => println!(
                "ERROR: could not mine proof zero, message: {:?}",
                &e.to_string()
            ),
        }
    }
}
