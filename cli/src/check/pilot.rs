//! `pilot` module

#![allow(clippy::never_loop)]
use crate::node::node::Node;
use crate::node::states::*;
use std::{thread, time::Duration};

/// run once
pub fn run_once(mut node: &mut Node, verbose: bool) -> &mut Node {
    if verbose {
        println!("PILOT\n...........................\n");
    }
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

    let is_in_val_set = node.vitals.items.validator_set;
    match is_in_val_set {
        true => {
            node.vitals.host_state.account_state = AccountState::InSet;
            if verbose {
                println!("Node: account is in validator set")
            }
        }
        false => {
            if verbose {
                println!("Node: account is NOT in validator set");
            }
            node.vitals.host_state.account_state = AccountState::ExistsOnChain;
            if !node.vitals.items.account_created {
                node.vitals.host_state.account_state = AccountState::None;
                if verbose {
                    println!(".. Account: Owner account does NOT exist on chain. Was the account creation transaction submitted?");
                }
            }
        }
    }

    // is node started?
    if !node.vitals.items.node_running {
        //     if verbose {
        //         println!("Node: node is running");
        //     }
        //     node.vitals.host_state.node_state = maybe_switch_mode(&mut node, is_in_val_set, verbose);
        // } else {
        // let start_mode = if is_in_val_set { Validator } else { Fullnode };

        if verbose {
            println!("Node: WARN: node is NOT running, starting node");
        }

        node.vitals.host_state.node_state = match node.start_node(verbose) {
            Ok(_) => NodeState::ValidatorOutOfSet,
            Err(_) => {
                println!(".. Node: WARN: could not start node");
                NodeState::Stopped
            }
        }
    }

    //////// MINER RULES ///////
    if node.vitals.items.miner_running {
        node.vitals.host_state.miner_state = TowerState::Mining;
        if verbose {
            println!("Miner: miner is running")
        }
    } else {
        node.vitals.host_state.miner_state = TowerState::Stopped;
        if verbose {
            println!("Miner: WARN: is NOT running");
        }
        if !node.vitals.items.node_running {
            if verbose {
                println!(
                    ".. Node: WARN: Node not running. Cannot start miner if node is not running"
                );
            }
        } else {
            // did the node finish sync?
            if node.vitals.items.is_synced {
                if verbose {
                    println!(".. Sync: node is synced");
                }

                // does the account exist on chain? otherwise sending mining txs will fail
                if node.vitals.items.account_created {
                    if verbose {
                        println!(".... Account: owner account found on-chain.");
                        println!(".... Miner: attempting to start miner.");
                    }
                    node.start_miner(verbose);
                    node.vitals.host_state.miner_state = TowerState::Mining;
                } else {
                    if verbose {
                        println!(".... Account: Owner account does NOT exist on chain. Was the account creation transaction submitted?")
                    }
                }
            } else {
                if verbose {
                    println!(".. Sync: node is NOT synced");
                    println!(".. Miner: WARN: cannot start miner until node is synced");
                }
            }
        }
    }
    thread::sleep(Duration::from_millis(10_000));
    node
}

// fn maybe_switch_mode(node: &mut Node, is_in_val_set: bool, verbose: bool) -> NodeState {
//     let running_mode = match Node::what_node_mode() {
//         Ok(t) => t,
//         Err(_) => return NodeState::Stopped,
//     };

//     if verbose {
//         println!(".. Mode: node running in mode: {:?}", running_mode);
//     }

//     let running_in_val_mode = running_mode == Validator;
//     // Running correctly as a FULLNODE
//     if !running_in_val_mode && !is_in_val_set {
//         if verbose {
//             println!(".... Mode: running the correct mode",);
//         }
//         return NodeState::FullnodeMode;
//     }
//     // Running correctly as a VALIDATOR
//     // Do nothing, the account is in validator set, and we are running as a validator
//     if running_in_val_mode && is_in_val_set {
//         if verbose {
//             println!(".... Mode: running the correct mode");
//         }
//         return NodeState::ValidatorMode;
//     }

//     // INCORRECT CASE 1: Need to change mode from Fullnode to Validator mode
//     if !running_in_val_mode && is_in_val_set {
//         if verbose {
//             println!(".... Mode: WARN: running the INCORRECT mode, switching to VALIDATOR mode");
//         }
//         node.stop_node();
//         node.start_node(verbose)
//             .expect("could not start node");

//         return NodeState::ValidatorMode;
//     }

//     // INCORRECT CASE 2: Need to change mode from Validator to Fullnode mode
//     if running_in_val_mode && !is_in_val_set {
//         if verbose {
//             println!(".... Mode: WARN: running the INCORRECT mode, switching to FULLNODE mode");
//         }
//         node.stop_node();
//         node.start_node(Validator, verbose)
//             .expect("could not start node");

//         return NodeState::FullnodeMode;
//     }

//     NodeState::Stopped
// }
