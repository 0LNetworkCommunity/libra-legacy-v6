//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::keygen;
use abscissa_core::{Command, Options, Runnable};

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateCmd {
    #[options(help = "don't generate keys")]
    skip_keys: bool,
}


impl Runnable for CreateCmd {
    /// Print version message
    fn run(&self) {
        if !self.skip_keys {
            let (_,_) = keygen::keygen();
        }
        
    }
}
