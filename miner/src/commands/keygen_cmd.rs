//! `submit` subcommand

#![allow(clippy::never_loop)]
use abscissa_core::{Command, Options, Runnable};

/// `keygen` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {}

impl Runnable for KeygenCmd {
    /// Print version message
    fn run(&self) {
        generate_keys();
    }
}

/// Reusable function for wizard
pub fn generate_keys() {
    keygen::keygen();
}
