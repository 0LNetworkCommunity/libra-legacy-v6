//! `version` subcommand

#![allow(clippy::never_loop)]

use super::OlCliCmd;
use crate::{entrypoint, node::client, node::node::Node, prelude::app_config};
use abscissa_core::{Command, Options, Runnable};
/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct PilotCmd {}

impl Runnable for PilotCmd {
    /// Print version message
    fn run(&self) {
        println!("{} {}", OlCliCmd::name(), OlCliCmd::version());
        // let mut n = NodeHealth::new();
        // Is webserver on?
        // call http? localhost:3030
        let args = entrypoint::get_args();
        let cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &cfg);
        let mut node = Node::new(client, cfg);

        if node.db_files_exist() {
            println!("DB files exist");
        // return
        } else {
            println!("No DB files found, try `ol restore`");
        }

        // is DB bootstrapped
        // if node.db_bootstrapped() {
        //     println!("Database bootstrapped");
        // } else {
        //     println!("Database was NOT bootstrapped");
        // }

        // Is in validator in set?

        if node.refresh_onchain_state().is_in_validator_set() {
          println!("in validator set");
        } else {
          println!("not in validator set");
        }
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
