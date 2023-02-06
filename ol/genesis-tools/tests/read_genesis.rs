mod support;

use support::{blob_path, read_db_and_compute_genesis};

use diem_genesis_tool::{self, verify::compute_genesis};
use diem_temppath::TempPath;
use std::path::PathBuf;
use diem_types::waypoint::Waypoint;
use storage_interface::DbReaderWriter;

#[test]
// A meta test, to see if db reading works as expected.
fn test_extract_waypoint() {
  let p = blob_path();

  let (_db, wp) = read_db_and_compute_genesis(p).expect("parse genesis.blob");
  dbg!(&wp.to_string());
  assert!(wp.to_string().starts_with("0:027c"));
}

// #[test]
// // read db.
// fn test_extract_waypoint() {
//   let p = blob_path();
//   let (db, wp) = read_db_and_compute_genesis(p).expect("parse genesis.blob");
  
  
// }