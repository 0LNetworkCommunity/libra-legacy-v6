//! `pilot` subcommand

#![allow(clippy::never_loop)]
use super::OlCliCmd;
use crate::node::states::*;
use crate::{
    entrypoint,
    mgmt::{
        self,
        management::NodeMode::{self, *},
    },
    node::client,
    node::node::Node,
    prelude::app_config,
};
use abscissa_core::{status_err, status_info, status_ok, status_warn, Command, Options, Runnable};
use libra_types::waypoint::Waypoint;
use std::{thread, time::Duration};

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct PilotCmd {}

impl Runnable for PilotCmd {
    /// Print version message
    fn run(&self) {
        println!("PILOT - {}", OlCliCmd::version());
        let args = entrypoint::get_args();
        let verbose = true;
        let mut cfg = app_config().clone();
        let (client, wp) = client::pick_client(args.swarm_path.clone(), &cfg)
            .expect("could not create connect a client");
        if args.swarm_path.is_some() {
            let mut tp = args.swarm_path.unwrap();
            tp.push("0");
            cfg.workspace.node_home = tp;
        }
        let mut node = Node::new(client, cfg.clone());
        pilot_db(&mut node, verbose);

        loop {
            pilot_once(&mut node, wp, verbose);
        }
    }
}

pub fn pilot_db(mut node: &mut Node, verbose: bool) -> &mut Node {
    let cfg = node.conf.to_owned();
    // let wp = node.client.waypoint().unwrap().to_owned();
    // Abort if the database is not set correctly.
    node.vitals.host_state.onboard_state = OnboardState::EmptyBox;

    if node.db_files_exist() {
        node.vitals.host_state.onboard_state = OnboardState::DbFilesOk;

        if verbose {
            status_ok!("DB", "db files exist");
        }
        // is DB bootstrapped
        if node.db_bootstrapped() {
            node.vitals.host_state.onboard_state = OnboardState::DbBootstrapOk;
            if verbose {
                status_ok!("DB", "db bootstrapped");
            }
        } else {
            if verbose {
                status_err!("libraDB is not bootstrapped. Database needs a valid set of transactions to boot. Attempting `ol restore` to fetch backups from archive.");
            }
            mgmt::restore::fast_forward_db(true).unwrap();
            node.vitals.host_state.onboard_state = OnboardState::DbBootstrapOk;
        }
    // return
    } else {
        if verbose {
            status_err!(
                "NO db files found {:?}. Attempting `ol restore` to fetch backups from archive.",
                &cfg.workspace.node_home
            );
        }
        mgmt::restore::fast_forward_db(true).unwrap();
        node.vitals.host_state.onboard_state = OnboardState::DbBootstrapOk;
    }
    node
}

pub fn pilot_once(mut node: &mut Node, wp: Waypoint, verbose: bool) {
    let cfg = node.conf.to_owned();

    if verbose {
        println!("==========================================");
    }
    // Start the webserver before anything else
    if Node::is_web_monitor_serving() {
        if verbose {
            status_ok!("Web", "web monitor is serving on 3030");
        }
    } else {
        if verbose {
            status_warn!("web monitor is NOT serving 3030. Attempting start.");
        }
        node.start_monitor();
    }

    // exit if cannot connect to any client, local or upstream.
    let is_in_val_set = node.refresh_onchain_state().is_in_validator_set();
    match is_in_val_set {
        true => {
            if verbose {
                status_ok!("Node", "account is in validator set")
            }
        }
        false => {
            if verbose {
                status_warn!("Node: account is NOT in validator set")
            }
        }
    }

    // is node started?
    if Node::node_running() {
        if verbose {
            status_ok!("Node", "node is running");
        }
        maybe_switch_mode(&mut node, is_in_val_set);
    } else {
        let start_mode = if is_in_val_set { Validator } else { Fullnode };

        if verbose {
            status_warn!("node is NOT running, starting in {:?} mode", start_mode);
        }

        node.start_node(start_mode).expect("could not start node");
    }

    //////// MINER RULES ////////
    if Node::miner_running() {
        if verbose {
            status_ok!("Miner", "miner is running")
        }
    } else {
        if verbose {
            status_warn!("miner is NOT running");
            status_info!("Miner", "will try to start miner");
        }
        if !Node::node_running() {
            if verbose {
                status_err!("Node not running. Cannot start miner if node is not running");
            }
        }
        // did the node finish sync?
        let sync_tup = Node::cold_start_is_synced(&cfg, wp);
        if sync_tup.0 {
            if verbose {
                status_ok!("Sync", "node is synced");
            }

            // does the account exist on chain? otherwise sending mining txs will fail
            if node.accounts_exist_on_chain() {
                if verbose {
                    status_ok!("Account", "owner account found on chain. Starting miner");
                }
                node.start_miner();
            } else {
                if verbose {
                    status_warn!("error trying to start miner. Owner account does NOT exist on chain. Was the account creation transaction submitted?")
                }
            }
        } else {
            if verbose {
                status_warn!("node is NOT Synced");
            }
        }
    }
    thread::sleep(Duration::from_millis(10_000));
}

fn maybe_switch_mode(node: &mut Node, is_in_val_set: bool) -> Option<NodeMode> {
    let running_mode = Node::what_node_mode().expect("could not detect node mode");
    status_ok!("Mode", "node running in mode: {:?}", running_mode);

    let running_in_val_mode = running_mode == Validator;
    // Running correctly as a FULLNODE
    if !running_in_val_mode && !is_in_val_set {
        status_ok!("Mode", "running the correct mode {:?}. Noop.", running_mode);
        return None;
    }
    // Running correctly as a VALIDATOR
    // Do nothing, the account is in validator set, and we are running as a validator
    if running_in_val_mode && is_in_val_set {
        status_ok!("Mode", "running the correct mode {:?}. Noop.", running_mode);
        return None;
    }

    // INCORRECT CASE 1: Need to change mode from Fullnode to Validator mode
    if !running_in_val_mode && is_in_val_set {
        status_warn!("Mode: running the INCORRECT mode, switching to VALIDATOR mode");
        node.stop_node();
        node.start_node(Validator).expect("could not start node");

        return Some(Validator);
    }

    // INCORRECT CASE 2: Need to change mode from Validator to Fullnode mode
    if running_in_val_mode && !is_in_val_set {
        status_warn!("Mode: running the INCORRECT mode, switching to FULLNODE mode");
        node.stop_node();
        node.start_node(Validator).expect("could not start node");

        return Some(Fullnode);
    }

    None
}
