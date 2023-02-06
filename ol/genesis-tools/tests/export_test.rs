mod support;

use support::path_utils::snapshot_path;
use std::fs;
use ol_genesis_tools::{process_snapshot::db_backup_into_recovery_struct, recover::save_recovery_file};

// The expected arguments of cli for exporting a V5 JSON recovery file from a db backup is:
// cargo r -p ol-genesis-tools -- --recover /opt/rec.json --snapshot-path /opt/state_ver*

#[tokio::test]
async fn test_parse_and_save() {
  let backup = snapshot_path();
  dbg!(&backup);
  assert!(backup.exists());

  let recovery = db_backup_into_recovery_struct(
    &backup, 
    false
  ).await
  .expect("could not export backup into json file");

  let output = backup.parent().unwrap().join("test_recovery.json");
  save_recovery_file(&recovery, &output.to_owned())
  .expect("ERROR: failed to create recovery from snapshot,");
  fs::remove_file(output).unwrap();
}