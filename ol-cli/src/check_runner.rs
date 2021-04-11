//! `monitor` subcommand

use std::{thread, time::{Duration}};
use crate::{chain_info, node_health::NodeHealth};
use std::io::{Write, stdout};
use crossterm::{QueueableCommand, cursor, terminal::{self, ClearType}};

/// Start the node monitor
pub fn mon(is_live: bool, print: bool) {

  let mut x = 0;
  let mut checker = NodeHealth::new();

  loop {
    checker.fetch_upstream_states();
    // refresh cahce for chain_info
    chain_info::fetch_chain_info();
    &checker.refresh_checks();
    &checker.items.write_cache();
    if print { print_it(&checker) }
    if !is_live && x==0 { break };
    x = x + 1;
    thread::sleep(Duration::from_millis(1000));
  }
}


fn print_it(checker: &NodeHealth) {
  let mut stdout = stdout();
  terminal::Clear(ClearType::All);
  stdout.queue(cursor::SavePosition).unwrap();
  stdout.write(
      format!(
"Configs Exist:{configs}
DB Restored: {restored}
Is Synced: {synced}
Sync Delay: {delay}
Node Running: {node}
Miner Running: {miner}
Account On Chain: {account}\n",
    configs = checker.items.configs_exist,
    restored = checker.items.db_restored,
    synced = checker.items.is_synced,
    delay = checker.items.sync_delay,
    node = checker.items.node_running,
    miner = checker.items.miner_running,
    account = checker.items.account_created,
    ).as_bytes()
  ).unwrap();

  stdout.queue(cursor::RestorePosition).unwrap();
  stdout.flush().unwrap();
}
