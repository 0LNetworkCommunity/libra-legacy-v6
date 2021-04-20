//! `monitor` subcommand

use crate::node::node::Node;
use crossterm::{
    cursor,
    terminal::{self, ClearType},
    QueueableCommand,
};
use std::io::{stdout, Write};
use std::{thread, time::Duration};

/// Start the node monitor
pub fn run_checks(mut node: Node, is_live: bool, print: bool) {
    let mut x = 0;
    loop {
        &node.refresh_onchain_state();
        &node.refresh_chain_info();
        &node.refresh_account_info();
        &node.refresh_checks();
        // &node.vitals.items.write_cache();
        if print { print_it(&node) }
        if !is_live && x == 0 { break; };
        x = x + 1;
        thread::sleep(Duration::from_millis(1000));
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
