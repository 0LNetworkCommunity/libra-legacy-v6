//! `version` subcommand

#![allow(clippy::never_loop)]

use super::OlCliCmd;
use abscissa_core::{Command, Options, Runnable};
use crate::management;
/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct VersionCmd {}

impl Runnable for VersionCmd {
    /// Print version message
    fn run(&self) {
        println!("{} {}", OlCliCmd::name(), OlCliCmd::version());
        management::run_validator_wizard();
    }
}
