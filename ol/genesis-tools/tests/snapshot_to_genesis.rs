mod support;

use ol_genesis_tools::fork_genesis::make_recovery_genesis_from_db_backup;
use std::fs;
use support::{path_utils::snapshot_path, test_vals};

#[tokio::test]
async fn test_read_db_backup_and_save_blob() {
    let genesis_vals = test_vals::get_test_valset(4);

    let db_backup_path = snapshot_path();
    let output_path = db_backup_path.parent().unwrap().join("fork_genesis.blob");
    make_recovery_genesis_from_db_backup(
      output_path.clone(), 
      db_backup_path, 
      false,
      &genesis_vals,
    )
        .await
        .expect("ERROR: could not create genesis from db backup");

    assert!(output_path.exists(), "file not created");
    fs::remove_file(output_path).unwrap();
}
