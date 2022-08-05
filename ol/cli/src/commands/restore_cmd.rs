//! `restore-cmd` subcommand

use crate::mgmt;
use abscissa_core::{Command, Options, Runnable};

/// `restore-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct RestoreCmd {
    #[options(help = "verbose logging of backup restore")]
    verbose: bool,

    #[options(short = "e", help = "what epoch to start restore from")]
    epoch: Option<u64>,

    #[options(
        short = "v",
        help = "specify a version or height if there is more than one per archive"
    )]
    version: Option<u64>,

    #[options(
        short = "l",
        help = "fetch the highest version available, of the latest epoch."
    )]
    latest_version: bool,
}

impl Runnable for RestoreCmd {
    /// Start the application.
    fn run(&self) {
        match mgmt::restore::fast_forward_db(
            self.verbose,
            self.epoch,
            self.version,
            self.latest_version,
        ) {
            Ok(_) => {
                println!("SUCCESS")
            }
            Err(e) => println!("ERROR: could not complete db restore, message: {:?}", e),
        };
    }
}
