mod support;

use ol_genesis_tools::{
    process_snapshot::db_backup_into_recovery_struct,
};
use ol_types::legacy_recovery::save_recovery_file;
use std::fs;
use support::path_utils::snapshot_path;

// The expected arguments of cli for exporting a V5 JSON recovery file from a db backup is:
// cargo r -p ol-genesis-tools -- --recover /opt/rec.json --snapshot-path /opt/state_ver*

#[tokio::test]
async fn snapshot_to_json() {
    let backup = snapshot_path().parent().unwrap().join("state_ver_119757649.17a8");
    assert!(backup.exists());

    let recovery = db_backup_into_recovery_struct(&backup)
        .await
        .expect("could not export backup into json file");

    let output = backup.parent().unwrap().join("test_recovery.json");
    save_recovery_file(&recovery, &output)
        .expect("ERROR: failed to create recovery from snapshot,");
    // fs::remove_file(output).unwrap();
}

