//! `monitor` subcommand

use crate::check::Check;
use crossterm::{cursor, QueueableCommand};
use std::io::{stdout, Write};
use std::{thread, time::Duration};

/// Start the node monitor
pub fn mon() {
    let mut stdout = stdout();

    let mut x = 0;
    let mut checker = Check::new();
    loop {
        thread::sleep(Duration::from_millis(1000));

        checker.fetch_upstream_states();

        // TODO: make keep cursor position
        let sync = checker.check_sync();
        let mining = match checker.miner_is_mining() {
            true => "Running",
            false => "Stopped",
        };
        let node_status = match checker.node_is_running() {
            true => "Running",
            false => "Stopped",
        };

        stdout.queue(cursor::SavePosition).unwrap();
        stdout.write(
            format!(
                "Test: {}, Is clean:{}, Is synced: {}, node: {}, miner: {}, Account on chain: {}, epoch: {}-{}, validator set:{}",
                &x,
                checker.is_clean_start(),
                &sync,
                node_status,
                mining,
                checker.accounts_exist_on_chain(),
                checker.epoch_on_chain(),
                checker.chain_height(),
                checker.is_in_validator_set(),
            ).as_bytes()
        ).unwrap();

        stdout.queue(cursor::RestorePosition).unwrap();
        stdout.flush().unwrap();

        x = x + 1;
    }
}

// TODO: Implement loop with clockwerk
use clokwerk::{Scheduler, TimeUnits};

/// set a timer for the monitor
pub fn timer() {
    let mut scheduler = Scheduler::new();
    scheduler
        .every(1.seconds())
        .run(|| println!("Periodic task"));

    let _thread_handle = scheduler.watch_thread(Duration::from_millis(100));
}
