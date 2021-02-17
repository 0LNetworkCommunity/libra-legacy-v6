//! `version` subcommand

#![allow(clippy::never_loop)]

// -------- gokhan
use crate::{submit_tx::{submit_tx_, eval_tx_status}};
use crate::{test_tx_swarm::{get_params_from_swarm}};

use std::path::PathBuf;
// --------

use super::MinerCmd;
use abscissa_core::{Command, Options, Runnable};

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct VersionCmd {}


impl Runnable for VersionCmd {
    /// Print version message
    fn run(&self) {
        println!("{} {}", MinerCmd::name(), MinerCmd::version());

        // -------- gokhan
        let swarm_path = PathBuf::from("./swarm_temp");
        let tx_params = get_params_from_swarm(swarm_path).unwrap();

        match submit_tx_(&tx_params) {
            Err(err) => { println!("{:?}", err) }
            Ok(res)  => {
                eval_tx_status(res);
            }
        }        
        // --------
        
    }
}
