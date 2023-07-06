mod support;

use ol_genesis_tools::{
    ancestry,
    process_snapshot::db_backup_into_recovery_struct,
};
use ol_types::legacy_recovery::save_recovery_file;
use support::path_utils::snapshot_path;
use crate::support::path_utils::json_path;
// The expected arguments of cli for exporting a V5 JSON recovery file from a db backup is:
// cargo r -p ol-genesis-tools -- --recover /opt/rec.json --snapshot-path /opt/state_ver*

#[tokio::test]
async fn fix_ancestry() {
    let backup = snapshot_path().parent().unwrap().join("state_ver_119757649.17a8");
    assert!(backup.exists());

    let mut recovery = db_backup_into_recovery_struct(&backup)
        .await
        .expect("could not export backup into json file");
    let output = backup.parent().unwrap().parent().unwrap().join("test_recovery_pre.json");
    save_recovery_file(&recovery, &output)
        .expect("ERROR: failed to create recovery from snapshot,");

    let p = json_path().parent().unwrap().join("ancestry_v7.json");
    let json_ancestry = ancestry::parse_ancestry_json(p).unwrap();
    let proper_ancestry = ancestry::map_ancestry(&json_ancestry).unwrap();
    ancestry::fix_legacy_recovery_data(&mut recovery, &proper_ancestry);

    let output = backup.parent().unwrap().parent().unwrap().join("test_recovery_post.json");
    save_recovery_file(&recovery, &output)
        .expect("ERROR: failed to create recovery from snapshot,");
    // fs::remove_file(output).unwrap();
}

