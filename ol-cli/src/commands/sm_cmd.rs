//! `sm-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::sm;

/// `sm-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct SMCmd {
    // ..
}

impl Runnable for SMCmd {

    /// Start the application.
    fn run(&self) {
        sm::node_state_machine::demo();
        sm::miner_state_machine::demo();
    }
}
