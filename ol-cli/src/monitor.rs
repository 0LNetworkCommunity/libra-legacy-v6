//! `monitor` subcommand


use std::{thread, time::{Duration}};
use crate::{
    check::Check,
};
use std::io::{Write, stdout};
use crossterm::{QueueableCommand, cursor};
use sled::{self};

/// Start the node monitor
pub fn mon() {    
    let mut stdout = stdout();

    let mut x = 0;
    loop {
        thread::sleep(Duration::from_millis(1000));

        // TODO: make keep cursor position
        let sync =  Check::check_sync();
        stdout.queue(cursor::SavePosition).unwrap();
        stdout.write(
            format!(
                "Test: {}, Is synced: {}", 
                &x,
                &sync,
            ).as_bytes()
        ).unwrap();

        stdout.queue(cursor::RestorePosition).unwrap();
        stdout.flush().unwrap();

        x = x + 1;
    }
}


// TODO: Implement loop with clockwerk
use clokwerk::{Scheduler, TimeUnits};

pub fn timer () {
    let mut scheduler = Scheduler::new();
    scheduler.every(1.seconds()).run(|| println!("Periodic task"));

    let thread_handle = scheduler.watch_thread(Duration::from_millis(100));
}