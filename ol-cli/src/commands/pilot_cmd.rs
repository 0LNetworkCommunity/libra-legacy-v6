//! `version` subcommand

#![allow(clippy::never_loop)]

use super::OlCliCmd;
use crate::{entrypoint, node::client, node::node::Node, prelude::app_config};
use abscissa_core::{Command, Options, Runnable, status_warn};
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
        let (client, wp) = client::pick_client(args.swarm_path, &cfg).expect("could not create connect a client");

        let mut node = Node::new(client, cfg.clone());

        if node.db_files_exist() {
            println!("db files exist");
        // return
        } else {
            status_warn!("NO db files found, try `ol restore`");
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
          status_warn!("owner NOT in validator set");
        }
        // is node started?
        if Node::node_running() {
          println!("node is running")
        } else {
          status_warn!("node is NOT running");
        }

        if Node::miner_running() {
          println!("miner is running")
        } else { 
          status_warn!("miner is NOT running");
        }

        // restart in validator mode

        // restart in fullnode mode

        // did the node finish sync
        if Node::cold_start_is_synced(&cfg, wp).0 {
          println!("node is synced");
        } else {
          status_warn!("node is NOT Synced");
        }

        // TODO: is the node making progress

        ////////////// MINING //////////////
        // does the account exist on chain?
        if node.accounts_exist_on_chain() {
          println!("owner account found on chain")
        } else {
          status_warn!("owner account does NOT exist on chain.")

        }

        // start miner
        // management::start_miner()

        // are transactions being successfully submitted?
        // TODO?
    }
}
