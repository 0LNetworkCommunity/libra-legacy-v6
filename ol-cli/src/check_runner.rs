//! `monitor` subcommand


use std::{thread, time::{Duration}};
use crate::{check::Check};
use std::io::{Write, stdout};
use crossterm::{QueueableCommand, cursor, terminal::{self, ClearType}};

/// Start the node monitor
pub fn mon(is_live: bool) {
    let mut stdout = stdout();

    let mut x = 0;
    let mut checker = Check::new();
    loop {
        thread::sleep(Duration::from_millis(1000));
        terminal::Clear(ClearType::All);
        checker.fetch_upstream_states();

        // TODO: make keep cursor position
        let sync_tuple = checker.check_sync();

        stdout.queue(cursor::SavePosition).unwrap();
        stdout.write(
            format!(
"Check-counter: {counter}
Configs Exist:{configs}
DB Restored: {restored}
Is Synced: {synced}
Sync Delay: {delay}
Node Running: {node}
Miner Running: {miner}
Account On Chain: {account}
Epoch: {epoch}
Height {height}
In Validator Set:{valset}",
                counter = &x,
                configs = checker.configs_exist(),
                restored = checker.database_bootstrapped(),
                synced = &sync_tuple.0,
                delay = &sync_tuple.1,
                node = checker.node_running(),
                miner = checker.miner_running(),
                account = checker.accounts_exist_on_chain(),
                epoch = checker.epoch_on_chain(),
                height = checker.chain_height(),
                valset = checker.is_in_validator_set(),
            ).as_bytes()
        ).unwrap();

        checker.items.write_cache();
        
        stdout.queue(cursor::RestorePosition).unwrap();
        stdout.flush().unwrap();

        if !is_live && x==0 { break };
        x = x + 1;
    }
}


// // TODO: Implement loop with clockwerk
// use clokwerk::{Scheduler, TimeUnits};

// /// set a timer for the monitor
// pub fn timer () {
//     let mut scheduler = Scheduler::new();
//     scheduler.every(1.seconds()).run(|| println!("Periodic task"));

//     let _thread_handle = scheduler.watch_thread(Duration::from_millis(100));
// }