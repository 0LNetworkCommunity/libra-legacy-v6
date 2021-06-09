//! `restore-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::mgmt;

/// `restore-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct RestoreCmd {
    #[options(short="v", help = "verbose logging of backup restore")]
    verbose: bool,
    #[options(short="e", help = "what epoch to start restore from")]
    epoch: Option<u64>,
}

impl Runnable for RestoreCmd {
    /// Start the application.
    fn run(&self) {
        mgmt::restore::fast_forward_db(self.verbose, self.epoch).unwrap();
    }
}