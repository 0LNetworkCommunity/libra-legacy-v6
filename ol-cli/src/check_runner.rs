//! `monitor` subcommand


use std::{thread, time::{Duration}};
use crate::{
    check::Check,
};
use std::io::{Write, stdout};
use crossterm::{QueueableCommand, cursor};

/// Start the node monitor
pub fn mon(is_live: bool) {
    let mut stdout = stdout();

    let mut x = 0;
    let mut checker = Check::new();
    loop {
        thread::sleep(Duration::from_millis(1000));

        checker.fetch_upstream_states();

        // TODO: make keep cursor position
        let sync = checker.check_sync();
        let mining = match checker.miner_is_mining() {
            true=> "running",
            false => "stopped"
        };
        let node_status = match checker.node_is_running() {
            true=> "running",
            false => "stopped"
        };

        stdout.queue(cursor::SavePosition).unwrap();
        stdout.write(
            format!(
                "Test: {}, Configs Exist:{}, Is synced: {}, Node app: {}, Miner app: {}, Account on chain: {}, Epoch: {}, Height {}, In val set:{}",
                &x,
                checker.configs_exist(),
                &sync,
                node_status,
                mining,
                checker.accounts_exist_on_chain(),
                checker.epoch_on_chain(),
                checker.chain_height(),
                checker.is_in_validator_set(),
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