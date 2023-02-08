mod support;

use ol_genesis_tools::fork_genesis::make_recovery_genesis_from_db_backup;
use std::fs;
use support::path_utils::snapshot_path;

#[tokio::test]
async fn test_read_db_backup_and_save_blob() {
    let genesis_vals = vec!["ADCB1D42A46292AE89E938BD982F2867".parse().unwrap()];

    let db_backup_path = snapshot_path();
    let output_path = db_backup_path.parent().unwrap().join("fork_genesis.blob");
    make_recovery_genesis_from_db_backup(
      output_path.clone(), 
      db_backup_path, 
      true, 
      false,
      genesis_vals,
    )
        .await
        .expect("ERROR: could not create genesis from db backup");

    assert!(output_path.exists(), "file not created");
    fs::remove_file(output_path).unwrap();
}
