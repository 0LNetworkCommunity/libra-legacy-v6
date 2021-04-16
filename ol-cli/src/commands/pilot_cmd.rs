//! `version` subcommand

#![allow(clippy::never_loop)]

use super::OlCliCmd;
use abscissa_core::{Command, Options, Runnable};
/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct PilotCmd {}

impl Runnable for PilotCmd {
    /// Print version message
    fn run(&self) {

        println!("{} {}", OlCliCmd::name(), OlCliCmd::version());
        // let mut n = NodeHealth::new();
        // // Is webserver on?
        // // call http? localhost:3030

        // // is DB bootstrapped
        // if !n.database_bootstrapped() {
        //     println!("Database was NOT bootstrapped");
        //     // return
        // } else {
        //   println!("Database bootstrapped");
        // }


        // // Is in validator in set?
        
        // if n.is_in_validator_set() {}
        // // is node started?
        // if n.node_running() {
        //   println!("node is running")
        // } else {println!("node is not running")}
        // if n.miner_running() {
        //   println!("miner is running")
        // } else { println!("miner is not running") }
        

        // // restart in validator mode

        // // restart in fullnode mode

        // // did the node finish sync
        // if NodeHealth::node_is_synced().0 {}
        
        // // TODO: is the node making progress

        // ////////////// MINING //////////////
        // // does the account exist on chain?
        // if n.accounts_exist_on_chain() {
        //     println!("Your account does NOT exist on chain.")
        // }

        // // start miner
        // // management::start_miner()

        // // are transactions being successfully submitted?
        // // TODO?
    }
}
