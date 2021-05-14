//! `pilot` module

#![allow(clippy::never_loop)]
use crate::node::states::*;
use crate::{
    mgmt::{self, management::NodeMode::*},
    node::node::Node,
};
use abscissa_core::{status_err, status_info, status_ok, status_warn};
use std::{thread, time::Duration};
// use gag::Gag;

/// check the db
pub fn maybe_restore_db(mut node: &mut Node, verbose: bool) -> &mut Node {
    let cfg = node.conf.to_owned();
    // let wp = node.client.waypoint().unwrap().to_owned();
    // Abort if the database is not set correctly.
    node.vitals.host_state.onboard_state = OnboardState::EmptyBox;

    // TODO: db.vitals.db_restored
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

/// run once
pub fn run_once(mut node: &mut Node, verbose: bool) -> &mut Node {
    let cfg = node.conf.to_owned();
    let wp = node.waypoint().unwrap();
    if verbose {
        println!("==========================================");
    }
    // Start the webserver before anything else
    if Node::is_web_monitor_serving() {
        node.vitals.host_state.monitor_state = MonitorState::Serving;

        if verbose {
            status_ok!("Web", "web monitor is serving on 3030");
        }
    } else {
        node.vitals.host_state.monitor_state = MonitorState::Stopped;

        if verbose {
            status_warn!("web monitor is NOT serving 3030. Attempting start.");
        }
        node.start_monitor(verbose);
        node.vitals.host_state.monitor_state = MonitorState::Serving;
    }

    // TODO: vitals.items.validator_set
    let is_in_val_set = node.refresh_onchain_state().is_in_validator_set();
    match is_in_val_set {
        true => {
            node.vitals.host_state.account_state = AccountState::InSet;
            if verbose {
                status_ok!("Node", "account is in validator set")
            }
        }
        false => {
            // TODO: we don't know if the account exists from the is_in_validator_set check
            node.vitals.host_state.account_state = AccountState::None;
            if verbose {
                status_warn!("Node: account is NOT in validator set")
            }
        }
    }

    // is node started?
    // TODO: vitals.node_running
    if Node::node_running() {
        if verbose {
            status_ok!("Node", "node is running");
        }
        node.vitals.host_state.node_state = maybe_switch_mode(&mut node, is_in_val_set, verbose);
    } else {
        let start_mode = if is_in_val_set { Validator } else { Fullnode };

        if verbose {
            status_warn!("node is NOT running, starting in {:?} mode", &start_mode);
        }

        node.vitals.host_state.node_state = match node.start_node(start_mode.clone(), verbose) {
            Ok(_) => match &start_mode {
                Validator => NodeState::ValidatorMode,
                Fullnode => NodeState::FullnodeMode,
            },
            Err(_) => {
                if verbose {
                    status_warn!(&format!("could not start node in: {:?}", &start_mode));
                }
                NodeState::Stopped
            }
        }
    }

    //////// MINER RULES ///////
    // TODO: vitals.node_running
    if Node::miner_running() {
        node.vitals.host_state.miner_state = MinerState::Mining;
        if verbose {
            status_ok!("Miner", "miner is running")
        }
    } else {
        node.vitals.host_state.miner_state = MinerState::Stopped;
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
        // vitals.items.is_synced
        let sync_tup = Node::cold_start_is_synced(&cfg, wp);
        if sync_tup.0 {
            if verbose {
                status_ok!("Sync", "node is synced");
            }

            // does the account exist on chain? otherwise sending mining txs will fail

            // TODO: vitals.items.account_created
            if node.accounts_exist_on_chain() {
                if verbose {
                    status_ok!("Account", "owner account found on chain. Starting miner");
                }
                node.start_miner(verbose);
                node.vitals.host_state.miner_state = MinerState::Mining;
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

    // drop(print_gag);
    node
}

fn maybe_switch_mode(node: &mut Node, is_in_val_set: bool, verbose: bool) -> NodeState {
    // let print_gag = Gag::stdout().unwrap();

    let running_mode = match Node::what_node_mode(){
        Ok(t)=> t,
        Err(_) => return NodeState::Stopped,
    };

    if verbose {
        status_ok!("Mode", "node running in mode: {:?}", running_mode);
    }

    let running_in_val_mode = running_mode == Validator;
    // Running correctly as a FULLNODE
    if !running_in_val_mode && !is_in_val_set {
        if verbose {
            status_ok!("Mode", "running the correct mode {:?}. Noop.", running_mode);
        }
        return NodeState::FullnodeMode;
    }
    // Running correctly as a VALIDATOR
    // Do nothing, the account is in validator set, and we are running as a validator
    if running_in_val_mode && is_in_val_set {
        if verbose {
            status_ok!("Mode", "running the correct mode {:?}. Noop.", running_mode);
        }
        return NodeState::ValidatorMode;
    }

    // INCORRECT CASE 1: Need to change mode from Fullnode to Validator mode
    if !running_in_val_mode && is_in_val_set {
        if verbose {
            status_warn!("Mode: running the INCORRECT mode, switching to VALIDATOR mode");
        }
        node.stop_node();
        node.start_node(Validator, verbose).expect("could not start node");

        return NodeState::ValidatorMode;
    }

    // INCORRECT CASE 2: Need to change mode from Validator to Fullnode mode
    if running_in_val_mode && !is_in_val_set {
        if verbose {
            status_warn!("Mode: running the INCORRECT mode, switching to FULLNODE mode");
        }
        node.stop_node();
        node.start_node(Validator, verbose).expect("could not start node");

        return NodeState::FullnodeMode;
    }

    NodeState::Stopped
}
