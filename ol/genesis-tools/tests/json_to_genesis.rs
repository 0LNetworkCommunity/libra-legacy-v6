mod support;

use ol_genesis_tools::{
    fork_genesis::make_recovery_genesis_from_vec_legacy_recovery, recover::read_from_recovery_file,
};
use std::fs;
use support::path_utils::json_path;

// The expected arguments of cli for exporting a V5 JSON recovery file from a db backup is:
// cargo r -p ol-genesis-tools -- --recover /opt/rec.json --snapshot-path /opt/state_ver*

#[tokio::test]
async fn test_parse_json_for_all_users_and_save_blob() {
    let recovery_json_path = json_path();
    let output_path = json_path().parent().unwrap().join("fork_genesis.blob");
    dbg!(&recovery_json_path);
    dbg!(&output_path);

    let recovery = read_from_recovery_file(&recovery_json_path);

    let len = recovery.len();
    dbg!(&len);

    make_recovery_genesis_from_vec_legacy_recovery(recovery, output_path.clone(), true)
        .expect("ERROR: failed to create genesis from recovery file");

    assert!(output_path.exists(), "file not created");
    fs::remove_file(output_path).unwrap();
}

#[tokio::test]
async fn test_parse_json_for_validators_and_save_blob() {
    let recovery_json_path = json_path();
    let output_path = json_path().parent().unwrap().join("fork_genesis.blob");
    dbg!(&recovery_json_path);
    dbg!(&output_path);

    let recovery = read_from_recovery_file(&recovery_json_path);

    make_recovery_genesis_from_vec_legacy_recovery(recovery, output_path.clone(), false)
        .expect("ERROR: failed to create genesis from recovery file");

    assert!(output_path.exists(), "file not created");
    fs::remove_file(output_path).unwrap();
}
