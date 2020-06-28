//! `submit` subcommand

#![allow(clippy::never_loop)]

use super::OlMinerCmd;
use abscissa_core::{Command, Options, Runnable};
use libra_types::waypoint::Waypoint;
// use crate:submit_tx::*;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct SubmitCmd {
    #[options(help = "Provide a waypoint for the libra chain")]
    waypoint: Waypoint,
}

impl Runnable for SubmitCmd {
    /// Print version message
    fn run(&self) {
        // submit_tx::create_account();
    }
}
