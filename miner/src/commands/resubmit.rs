//! `start` subcommand - example of how to write a subcommand

// use crate::block::Block;

use crate::config::OlMinerConfig;
use crate::prelude::*;
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use crate::resubmit_tx::resubmit_backlog;
use std::path::PathBuf;

/// `start` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct ResubmitCmd {
    #[options(help = "Provide a waypoint for the libra chain")]
    waypoint: String, //Option<Waypoint>,

    #[options(help = "Provide a waypoint for the libra chain")]
    home: PathBuf, 
}

impl Runnable for ResubmitCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();
        resubmit_backlog(self.home.to_owned(), &miner_configs);
    }
}
