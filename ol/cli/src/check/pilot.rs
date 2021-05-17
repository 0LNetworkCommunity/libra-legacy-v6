//! `pilot` module

#![allow(clippy::never_loop)]
use crate::node::states::*;
use crate::{
    mgmt::{self, management::NodeMode::*},
    node::node::Node,
};
use std::{thread, time::Duration};

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
            println!("DB: db files exist");
        }
        // is DB bootstrapped
        if node.db_bootstrapped() {
            node.vitals.host_state.onboard_state = OnboardState::DbBootstrapOk;
            if verbose {
                println!("DB: db bootstrapped");
            }
        } else {
            if verbose {
                println!("DB: WARN: libraDB is not bootstrapped. Database needs a valid set of transactions to boot. Attempting `ol restore` to fetch backups from archive.");
            }
            mgmt::restore::fast_forward_db(true).unwrap();
            node.vitals.host_state.onboard_state = OnboardState::DbBootstrapOk;
        }
    // return
    } else {
        if verbose {
            println!(
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
  if verbose { println!("========= PILOT =========")}
    // Start the webserver before anything else
    if node.vitals.items.web_running {
        node.vitals.host_state.monitor_state = MonitorState::Serving;

        if verbose {
            println!("Web: web monitor is serving on 3030");
        }
    } else {
        node.vitals.host_state.monitor_state = MonitorState::Stopped;

        if verbose {
            println!("Web: WARN: web monitor is NOT serving on 3030. Attempting start.");
        }
        node.start_web(verbose);
        node.vitals.host_state.monitor_state = MonitorState::Serving;
    }

    // TODO: vitals.items.validator_set
    let is_in_val_set = node.vitals.items.validator_set;
    match is_in_val_set {
        true => {
            node.vitals.host_state.account_state = AccountState::InSet;
            if verbose {
                println!("Node: account is in validator set")
            }
        }
        false => {
            // TODO: we don't know if the account exists from the is_in_validator_set check
            node.vitals.host_state.account_state = AccountState::None;
            if verbose {
                println!("Node: account is NOT in validator set")
            }
        }
    }

    // is node started?
    // TODO: vitals.node_running
    if node.vitals.items.node_running {
        if verbose {
            println!("Node: node is running");
        }
        node.vitals.host_state.node_state = maybe_switch_mode(&mut node, is_in_val_set, verbose);
    } else {
        let start_mode = if is_in_val_set { Validator } else { Fullnode };

        if verbose {
            println!("Node: WARN: node is NOT running, starting in {:?} mode", &start_mode);
        }

        node.vitals.host_state.node_state = match node.start_node(start_mode.clone(), verbose) {
            Ok(_) => match &start_mode {
                Validator => NodeState::ValidatorMode,
                Fullnode => NodeState::FullnodeMode,
            },
            Err(_) => {
                if verbose {
                    println!("Node: WARN: could not start node in: {:?}", &start_mode);
                }
                NodeState::Stopped
            }
        }
    }

    //////// MINER RULES ///////
    if node.vitals.items.miner_running {
        node.vitals.host_state.miner_state = MinerState::Mining;
        if verbose {
            println!("Miner: miner is running")
        }
    } else {
        node.vitals.host_state.miner_state = MinerState::Stopped;
        if verbose {
            println!("Miner: WARN: is NOT running");
            println!("Miner: will try to start miner");
        }
        if !node.vitals.items.node_running  {
            if verbose {
                println!("Miner: WARN: Node not running. Cannot start miner if node is not running");
            }
        }
        // did the node finish sync?
        if node.vitals.items.is_synced {
            if verbose {
                println!("Sync: node is synced");
            }

            // does the account exist on chain? otherwise sending mining txs will fail
            if node.vitals.items.account_created {
                if verbose {
                    println!("Account: owner account found on-chain. Starting miner");
                }
                node.start_miner(verbose);
                node.vitals.host_state.miner_state = MinerState::Mining;
            } else {
                if verbose {
                    println!("ERROR trying to start miner. Owner account does NOT exist on chain. Was the account creation transaction submitted?")
                }
            }
        } else {
            if verbose {
                println!("Sync: node is NOT Synced");
            }
        }
    }
    thread::sleep(Duration::from_millis(10_000));
    node
}

fn maybe_switch_mode(node: &mut Node, is_in_val_set: bool, verbose: bool) -> NodeState {
    let running_mode = match Node::what_node_mode(){
        Ok(t)=> t,
        Err(_) => return NodeState::Stopped,
    };

    if verbose {
        println!("Mode: node running in mode: {:?}", running_mode);
    }

    let running_in_val_mode = running_mode == Validator;
    // Running correctly as a FULLNODE
    if !running_in_val_mode && !is_in_val_set {
        if verbose {
            println!("Mode: running the correct mode {:?}.", running_mode);
        }
        return NodeState::FullnodeMode;
    }
    // Running correctly as a VALIDATOR
    // Do nothing, the account is in validator set, and we are running as a validator
    if running_in_val_mode && is_in_val_set {
        if verbose {
            println!("Mode: running the correct mode {:?}.", running_mode);
        }
        return NodeState::ValidatorMode;
    }

    // INCORRECT CASE 1: Need to change mode from Fullnode to Validator mode
    if !running_in_val_mode && is_in_val_set {
        if verbose {
            println!("Mode: WARN: running the INCORRECT mode, switching to VALIDATOR mode");
        }
        node.stop_node();
        node.start_node(Validator, verbose).expect("could not start node");

        return NodeState::ValidatorMode;
    }

    // INCORRECT CASE 2: Need to change mode from Validator to Fullnode mode
    if running_in_val_mode && !is_in_val_set {
        if verbose {
            println!("Mode: WARN: running the INCORRECT mode, switching to FULLNODE mode");
        }
        node.stop_node();
        node.start_node(Validator, verbose).expect("could not start node");

        return NodeState::FullnodeMode;
    }

    NodeState::Stopped
}
