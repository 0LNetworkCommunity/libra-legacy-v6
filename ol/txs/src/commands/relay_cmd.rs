//! `relay` subcommand

#![allow(clippy::never_loop)]

use crate::relay::relay_from_file;
use abscissa_core::{Command, Options, Runnable};
use std::{path::PathBuf, process::exit};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Options)]
pub struct RelayCmd {
    /// File with a signed transaction which the relayer will send
    #[options(short = "f", help = "Path to relay file")]
    relay_file: PathBuf,
}

impl Runnable for RelayCmd {
    fn run(&self) {
        match relay_from_file(self.relay_file.clone()) {
            Err(e) => {
                println!("ERROR: could not relay transaction, message: \n{:?}", &e);
                exit(1);
            }
            _ => {}
        }
    }
}
