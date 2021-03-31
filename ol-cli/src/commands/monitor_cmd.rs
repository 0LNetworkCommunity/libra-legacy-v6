//! `monitor-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::check_runner;

/// `monitor-cmd` subcommand
#[derive(Command, Debug, Options)]
pub struct MonitorCmd {}

impl Runnable for MonitorCmd {
    /// Start the application.
    fn run(&self) {

        // TODO: wrap ../explorer
        check_runner::mon(true);
    }
}
