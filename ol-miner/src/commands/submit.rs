//! `submit` subcommand

#![allow(clippy::never_loop)]

use super::OlMinerCmd;
use abscissa_core::{Command, Options, Runnable};
use crate::submit_tx::*;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct SubmitCmd {}

impl Runnable for SubmitCmd {
    /// Print version message
    fn run(&self) {
        submit_tx::create_account();
    }
}
