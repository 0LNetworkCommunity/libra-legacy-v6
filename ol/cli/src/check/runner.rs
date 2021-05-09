//! `monitor` subcommand

use super::pilot;
use crate::node::node::Node;
use crossterm::{
    cursor,
    terminal::{self, ClearType},
    QueueableCommand,
};
use std::io::{stdout, Write};
use std::{thread, time::Duration};

/// Start the node monitor
pub fn run_checks(mut node: &mut Node, pilot: bool, is_live: bool, verbose: bool) {
    if pilot {
        pilot::maybe_restore_db(&mut node, verbose);
    }
    loop {
        // Make changes first, then check after
        if pilot {
            pilot::run_once(&mut node, verbose);
        }
        // update all the checks
        check_once(&mut node, verbose);
        if !is_live {
            break;
        };
        thread::sleep(Duration::from_millis(1000));
    }
}

// let args = entrypoint::get_args();
// let verbose = true;
// let mut cfg = app_config().clone();
// let (client, wp) = client::pick_client(args.swarm_path.clone(), &cfg)
//     .expect("could not create connect a client");
// if args.swarm_path.is_some() {
//     let mut tp = args.swarm_path.unwrap();
//     tp.push("0");
//     cfg.workspace.node_home = tp;
// }
// let mut node = Node::new(client, cfg.clone());
// pilot::maybe_restore_db(&mut node, verbose);

// loop {
//     pilot::run_once(&mut node, wp, verbose);
// }

/// Run healtchecks once
pub fn check_once(node: &mut Node, verbose: bool) {
    let home_path = node.conf.workspace.node_home.clone();

    &node.refresh_onchain_state();
    &node.refresh_chain_info();
    &node.refresh_account_info();
    &node.refresh_checks();
    &node.vitals.write_json(&home_path);
    if verbose {
        print_it(&node)
    }
}

fn print_it(node: &Node) {
    let mut stdout = stdout();
    terminal::Clear(ClearType::All);
    stdout.queue(cursor::SavePosition).unwrap();
    stdout
        .write(
            format!(
                "Configs exist:{configs}
DB restored: {restored}
Is synced: {synced}
Sync delay: {delay}
Node running: {node}
Miner running: {miner}
Account on chain: {account}
In validator set: {in_set}
\n",
                configs = node.vitals.items.configs_exist,
                restored = node.vitals.items.db_restored,
                synced = node.vitals.items.is_synced,
                delay = node.vitals.items.sync_delay,
                node = node.vitals.items.node_running,
                miner = node.vitals.items.miner_running,
                account = node.vitals.items.account_created,
                in_set = node.vitals.items.validator_set,
            )
            .as_bytes(),
        )
        .unwrap();

    stdout.queue(cursor::RestorePosition).unwrap();
    stdout.flush().unwrap();
}
