//! `monitor` subcommand

use super::pilot;
use crate::node::node::Node;
use chrono::Utc;
use std::{thread, time::Duration};

/// Start the node monitor
pub fn run_checks(
    mut node: &mut Node,
    pilot: bool,
    is_live: bool,
    verbose_check: bool,
    verbose_pilot: bool,
) {
    loop {
        // update all the checks
        node.check_once(verbose_check);

        if pilot {
            pilot::run_once(&mut node, verbose_pilot);
        }
        if !is_live {
            break;
        };
        thread::sleep(Duration::from_millis(30_000));
    }
}

impl Node {
    /// Run healtchecks once
    pub fn check_once(&mut self, verbose: bool) -> &mut Self {
        let home_path = self.app_conf.workspace.node_home.clone();

        &self.refresh_onchain_state();
        &self.refresh_chain_info();
        &self.refresh_account_info();
        &self.refresh_checks();
        &self.vitals.write_json(&home_path);
        if verbose {
            print_it(&self)
        }

        self
    }
}

fn print_it(node: &Node) {
    println!(
        "
{now}\n
HEALTH\n...........................\n
Configs exist: {configs}
DB restored: {restored}
Web monitor: {web_running}
Is synced: {synced}
Local DB Version: {version}
Sync delay: {delay}
Node running: {node}
Tower running: {miner}
Account on chain: {account}
In validator set: {in_set}
\n",
        now = Utc::now().format("%Y-%m-%d %H:%M:%S").to_string(),
        configs = node.vitals.items.configs_exist,
        restored = node.vitals.items.db_restored,
        web_running = node.vitals.items.web_running,
        synced = node.vitals.items.is_synced,
        version = node.vitals.items.sync_height,
        delay = node.vitals.items.sync_delay,
        node = node.vitals.items.node_running,
        miner = node.vitals.items.miner_running,
        account = node.vitals.items.account_created,
        in_set = node.vitals.items.validator_set,
    );
}
