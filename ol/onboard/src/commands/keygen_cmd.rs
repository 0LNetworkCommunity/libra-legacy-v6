//! `keygen` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use ol_keys::wallet;

/// `keygen` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {}

impl Runnable for KeygenCmd {
    fn run(&self) {
        wallet::keygen();
    }
}
