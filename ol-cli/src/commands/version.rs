//! `version` subcommand

#![allow(clippy::never_loop)]

use super::OlCliCmd;
use abscissa_core::{Command, Options, Runnable};
use crate::chain_info;
/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct VersionCmd {}

impl Runnable for VersionCmd {
    /// Print version message
    fn run(&self) {
        println!("{} {}", OlCliCmd::name(), OlCliCmd::version());
        println!("{:?}", chain_info::fetch_chain_info());

    }
}
