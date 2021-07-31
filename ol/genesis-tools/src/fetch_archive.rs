//! fetches archive files from github

use ol::mgmt::restore::{Backup, fast_forward_db};
use anyhow::Result;

/// daemon for waiting for an epoch archive to be published
pub fn wait_for_archive(epoch: Option<u64>) -> Result<()>{
  loop {
    // check every 60 secs.
    thread::sleep(time::Duration::from_millis(60_000));
    match fast_forward_db(true, epoch) {
      Ok(_) => Ok(()),
      Err(_) => print!("."),
    };
  }

  Ok(())
}


#[test]
fn test_fetch() {

}