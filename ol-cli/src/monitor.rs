//! `monitor` subcommand


use std::{thread, time::{Duration}};
use crate::metadata::Metadata;
use std::io::{Write, stdout};
use crossterm::{QueueableCommand, cursor};
use sled::{self, IVec};
/// Monitor placeholder
pub struct Monitor {}

const SYNC_KEY: &str = "is_synced";

impl Monitor {
    /// Checks if node is synced
    pub fn is_synced() -> bool {
        Metadata::compare_from_config() < 1000
    }

    /// Check if node caught up, if so mark as caught up.
    pub fn check_sync() -> bool {
        let sync = Monitor::is_synced();
        // let have_ever_synced = false;
        // assert never synced
        if !Monitor::has_ever_synced() && sync {
            // mark as synced
            Monitor::write_db(SYNC_KEY, "true");

        }
        sync  
    }

    pub fn has_ever_synced() -> bool {
        Monitor::read_db(SYNC_KEY) == b"true"
    }

    /// Persist Monitor state
    pub fn write_db(key: &str, value: &str) {
        let tree = sled::open("/tmp/welcome-to-sled").expect("open");
        tree.insert(key.as_bytes(), value);
    }

    /// Read Monitor state
    pub fn read_db(key: &str) -> IVec {
        let tree = sled::open("/tmp/welcome-to-sled").expect("open");
        tree.get(key).unwrap().unwrap()
    }
}

/// Start the node monitor
pub fn mon() {

    let mut stdout = stdout();

    let mut x = 0;
    loop {
        thread::sleep(Duration::from_millis(1000));

        // TODO: make keep cursor position
        let sync =  Monitor::check_sync();
        stdout.queue(cursor::SavePosition);
        stdout.write(
            format!(
                "Test: {}, Is synced: {}", 
                &x,
                &sync,
            ).as_bytes()
        );

        stdout.queue(cursor::RestorePosition);
        stdout.flush();

        x = x + 1;
    }
}