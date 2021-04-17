//! `monitor` subcommand

use crate::{
    node::account::OwnerAccountView,
    node::node::Node,
};

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
    // let mut node = NodeHealth::new(Some(client.clone()), cfg);
    let _account = OwnerAccountView::new(node.conf.profile.account);

    loop {
        node.fetch_upstream_states();
        // refresh cahce for chain_info
        // chain_info::fetch_chain_info(&mut node.client.unwrap());
        &node.refresh_checks();
        // &account.refresh(&mut node.client.unwrap(), node.conf);
        &node.items.write_cache();
        if print {
            print_it(&node)
        }
        if !is_live && x == 0 {
            break;
        };
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
                configs = node.items.configs_exist,
                restored = node.items.db_restored,
                synced = node.items.is_synced,
                delay = node.items.sync_delay,
                node = node.items.node_running,
                miner = node.items.miner_running,
                account = node.items.account_created,
                in_set = node.items.validator_set,
            )
            .as_bytes(),
        )
        .unwrap();

    stdout.queue(cursor::RestorePosition).unwrap();
    stdout.flush().unwrap();
}
