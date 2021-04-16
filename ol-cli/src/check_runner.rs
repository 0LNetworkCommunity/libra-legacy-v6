//! `monitor` subcommand

use std::{thread, time::{Duration}};
use crate::{chain_info, node_health::NodeHealth, account::AccountInfo};
use std::io::{Write, stdout};
use cli::libra_client::LibraClient;
use crossterm::{QueueableCommand, cursor, terminal::{self, ClearType}};

/// Start the node monitor
pub fn mon(mut client: LibraClient, is_live: bool, print: bool) {
  let mut x = 0;
  let mut checker = NodeHealth::new();
  let mut account = AccountInfo::new();

  loop {
    checker.fetch_upstream_states();
    // refresh cahce for chain_info
    chain_info::fetch_chain_info(&mut client);
    &checker.refresh_checks();
    &account.refresh();
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
"Configs exist:{configs}
DB restored: {restored}
Is synced: {synced}
Sync delay: {delay}
Node running: {node}
Miner running: {miner}
Account on chain: {account}
In validator set: {in_set}
\n",
    configs = checker.items.configs_exist,
    restored = checker.items.db_restored,
    synced = checker.items.is_synced,
    delay = checker.items.sync_delay,
    node = checker.items.node_running,
    miner = checker.items.miner_running,
    account = checker.items.account_created,
    in_set = checker.items.validator_set,
    ).as_bytes()
  ).unwrap();

  stdout.queue(cursor::RestorePosition).unwrap();
  stdout.flush().unwrap();
}
