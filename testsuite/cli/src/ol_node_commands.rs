use crate::{
    client_proxy::ClientProxy,
    commands::{subcommand_execute, Command},
};

use chrono::{DateTime, Utc};
use diem_types::waypoint::Waypoint;
use std::time::{Duration, UNIX_EPOCH};
// use diem_json_rpc_client::views::MinerStateResourceView;
// use anyhow::Error;

/// Major command for query operations.
pub struct NodeCommand {}

impl Command for NodeCommand {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["node", "n"]
    }
    fn get_description(&self) -> &'static str {
        "Get state of validators, miners."
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        let commands: Vec<Box<dyn Command>> = vec![
            Box::new(CommandQueryMinerState {}),
            Box::new(CommandGenWaypoint {}),
        ];

        subcommand_execute(&params[0], commands, client, &params[1..]);
    }
}

/// Sub commands to query balance for the account specified.
pub struct CommandQueryMinerState {}

impl Command for CommandQueryMinerState {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["get_miner_state", "ms"]
    }
    fn get_params_help(&self) -> &'static str {
        "<account_address>"
    }
    fn get_description(&self) -> &'static str {
        "Get miner state for a address"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        match client.get_miner_state(&params) {
            Ok( Some(msv)) => println!(" Account: {:?}\n {:?}", &params[1], msv ),
            Err(e) => println!("Didn't find miner state for this address: {:?}", e),
            _ => {}
        }
    }
}

pub struct CommandGenWaypoint {}

impl Command for CommandGenWaypoint {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["gen_waypoint"]
    }

    fn get_params_help(&self) -> &'static str {
        ""
    }

    fn get_description(&self) -> &'static str {
        "Generate a waypoint for the latest epoch change LedgerInfo"
    }

    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        if params.len() != 1 {
            println!("No parameters required for waypoint generation");
            return;
        }
        println!("Retrieving the uptodate ledger info...");
        if let Err(e) = client.test_validator_connection() {
            println!("Failed to get uptodate ledger info connection: {}", e);
            return;
        }

        let latest_epoch_change_li = match client.latest_epoch_change_li() {
            Some(li) => li,
            None => {
                println!("No epoch change LedgerInfo found");
                return;
            }
        };
        let li_time_str = DateTime::<Utc>::from(
            UNIX_EPOCH
                + Duration::from_micros(latest_epoch_change_li.ledger_info().timestamp_usecs()),
        );
        match Waypoint::new_epoch_boundary(latest_epoch_change_li.ledger_info()) {
            Err(e) => println!("Failed to generate a waypoint: {}", e),
            Ok(waypoint) => println!(
                "Waypoint (end of epoch {}, time {}): {}",
                latest_epoch_change_li.ledger_info().epoch(),
                li_time_str,
                waypoint
            ),
        }
    }
}
