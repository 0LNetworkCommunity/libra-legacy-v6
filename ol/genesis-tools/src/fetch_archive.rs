//! fetches archive files from github

use std::{thread, time};

use anyhow::Result;
use ol::mgmt::restore::fast_forward_db;

/// daemon for waiting for an epoch archive to be published
pub fn wait_for_archive(epoch: Option<u64>) -> Result<()> {
    loop {
        // check every 60 secs.
        thread::sleep(time::Duration::from_millis(60_000));
        match fast_forward_db(true, epoch, None, true) {
            Ok(_) => return Ok(()),
            Err(_) => print!("."),
        };
    }
}

#[test]
fn test_fetch() {}
