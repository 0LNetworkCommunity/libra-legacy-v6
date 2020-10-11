use crate::{
    client_proxy::ClientProxy,
    commands::{report_error, subcommand_execute, Command},
};

use chrono::{DateTime, Utc};
use libra_types::waypoint::Waypoint;
use std::time::{Duration, UNIX_EPOCH};

/// Major command for query operations.
pub struct OLCommand {}

impl Command for OLCommand {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["ol"]
    }
    fn get_description(&self) -> &'static str {
        "0L commands"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        let commands: Vec<Box<dyn Command>> = vec![
            Box::new(OLCommandSentProof {}),
            Box::new(OLCommandQueryMinerState {}),
            Box::new(OLCommandGenWaypoint {}),
        ];

        subcommand_execute(&params[0], commands, client, &params[1..]);
    }
}

/// Sub commands to query balance for the account specified.
pub struct OLCommandSentProof {}

impl Command for OLCommandSentProof {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["send_proof", "s"]
    }
    fn get_params_help(&self) -> &'static str {
        "<preimage> <difficulty> <proof>"
    }
    fn get_description(&self) -> &'static str {
        "Send VDF proof transaction"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        // if params.len() != 4 {
        //     println!("Invalid number of arguments for balance query");
        //     return;
        // }
        match client.send_proof(&params, true) {
            Ok( _) => println!("succeed." ),
            Err(e) => report_error("Failed to send proof", e),
        }
    }
}

/// Sub commands to query balance for the account specified.
pub struct OLCommandQueryMinerState {}

impl Command for OLCommandQueryMinerState {
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
        match client.query_miner_state_in_client(&params) {
            Some( msv) => println!(" Account: {:?}\n {:?}", &params[1], msv ),
            None => {},
        }
    }
}

pub struct OLCommandGenWaypoint {}

impl Command for OLCommandGenWaypoint {
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
