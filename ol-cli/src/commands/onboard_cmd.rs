//! `onboard-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::onboard;

/// `onboard-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct OnboardCmd {
    // ..
}

impl Runnable for OnboardCmd {

    /// Start the application.
    fn run(&self) {
        onboard::onboard();
    }
}