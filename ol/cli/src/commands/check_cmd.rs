//! `monitor-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::check_runner;

/// `monitor-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct CheckCmd {
    /// Runs continuously
    #[options(no_short, help = "is live")]
    live: bool
}

impl Runnable for CheckCmd {
    /// Start the application.
    fn run(&self) {
        check_runner::mon(self.live);
        // monitor::timer();

        // Your code goes here
    }
}
