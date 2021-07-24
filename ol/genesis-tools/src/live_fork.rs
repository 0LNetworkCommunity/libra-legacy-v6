//! live-fork

use crate::fetch_archive::wait_for_archive;
use anyhow::Result;

/// starts the daemon for the live fork.
pub fn fork_daemon() -> Result<()> {
    match wait_for_archive() {
        Ok(_) => {
            // generate_genesis_from_snapshot
            match restart() {
                Ok(_) => Ok(()),
                Err(e) => Err(e),
            }
        }
        Err(e) => Err(e),
    }
}

/// restart node from new genesis.blob from archive
pub fn restart() -> Result<()> {
    kill_all_services();

    ol_start();
    Ok(())
}

fn kill_all_services() {
    todo!()
}

fn ol_start() {
    todo!()
}
