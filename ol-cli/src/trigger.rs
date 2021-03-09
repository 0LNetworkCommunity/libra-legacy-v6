//! `monitor` subcommand


use std::{thread, time::{Duration}};
use crate::metadata::Metadata;
use std::io::{Write, stdout};
use crossterm::{QueueableCommand, cursor};

/// Start the node monitor
pub fn mon() {
    let mut stdout = stdout();
    let mut x = 0;
    loop {
        thread::sleep(Duration::from_millis(1000));
        // prevent all the logging the client does while it loops through the query.
        // stdout().flush().unwrap();
        Metadata::compare_from_config();

        // TODO: make keep cursor position
        stdout.queue(cursor::SavePosition);
        stdout.write(format!("Here!!! {}", &x).as_bytes());
        stdout.queue(cursor::RestorePosition);
        stdout.flush();

        x = x + 1;
    }
}