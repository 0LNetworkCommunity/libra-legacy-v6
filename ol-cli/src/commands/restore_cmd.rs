//! `restore-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::restore;

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
}

impl Runnable for RestoreCmd {
    /// Start the application.
    fn run(&self) {
        restore::fast_forward_db(self.verbose).unwrap();
    }
}