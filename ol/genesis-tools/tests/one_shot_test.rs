use std::{path::PathBuf, fs, str::FromStr};
// use std::str ::FromStr;
// use diem_wallet::io_utils::recover;
use ol_genesis_tools::{process_snapshot::db_backup_into_recovery_struct, recover::{save_recovery_file, read_from_recovery_file}, fork_genesis::{make_recovery_genesis_from_db_backup, make_recovery_genesis_from_vec_legacy_recovery}};



#[tokio::test]
async fn test_read_db_backup_and_save_blob() {
  let db_backup_path = snapshot_path();
  let output_path = db_backup_path.parent().unwrap().join("fork_genesis.blob");
  make_recovery_genesis_from_db_backup(
    output_path.clone(), 
    db_backup_path, 
    true, 
    false
  ).await.expect("ERROR: could not create genesis from db backup");

  assert!(output_path.exists(), "file not created");
  fs::remove_file(output_path);
}

fn snapshot_path() -> PathBuf{
  use std::path::Path;
  let path = env!("CARGO_MANIFEST_DIR");
  Path::new(path)
    .parent()
    .unwrap()
    .parent()
    .unwrap()
    .join("ol/fixtures/rescue/state_backup/state_ver_76353076.a0ff").to_owned()

}