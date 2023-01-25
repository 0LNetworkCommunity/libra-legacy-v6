//! live-fork

use crate::fetch_archive::wait_for_archive;
use anyhow::Result;

/// starts the daemon for the live fork.
pub fn fork_daemon(epoch: Option<u64>) -> Result<()> {
    if !archive_exists() {
        wait_for_archive(epoch)?;
    };
    // generate_genesis_from_snapshot
    match restart() {
        Ok(_) => Ok(()),
        Err(e) => Err(e),
    }
}

fn _is_epoch() -> bool {
    true
}

fn _create_backup() -> Result<()> {
    Ok(())
}

fn archive_exists() -> bool {
    true
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
