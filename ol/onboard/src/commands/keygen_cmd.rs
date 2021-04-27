//! `version` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use keygen;
/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {}


impl Runnable for KeygenCmd {
    /// Print version message
    fn run(&self) {
        keygen::keygen();
    }
}
