mod support;

use ol_genesis_tools::{
    fork_genesis::make_recovery_genesis_from_vec_legacy_recovery,
    compare,
};
use ol_types::legacy_recovery::read_from_recovery_file;
use std::fs;
use support::{path_utils::json_path, test_vals};
// The expected arguments of cli for exporting a V5 JSON recovery file from a db backup is:
// cargo r -p ol-genesis-tools -- --recover /opt/rec.json --snapshot-path /opt/state_ver*

#[tokio::test]
async fn test_parse_json_for_all_users_and_save_blob() {
    let genesis_vals = test_vals::get_test_valset(4);

    let recovery_json_path = json_path();
    let output_path = json_path().parent().unwrap().join("fork_genesis.blob");

    let recovery = read_from_recovery_file(&recovery_json_path);

    make_recovery_genesis_from_vec_legacy_recovery(
      &recovery,
      &genesis_vals,
      output_path.clone(), 
      true
    )
    .expect("ERROR: failed to create genesis from recovery file");

    assert!(output_path.exists(), "file not created");
    
    let list = compare::compare_json_to_genesis_blob(recovery_json_path, output_path.clone()).unwrap();

    assert!(list.is_empty(), "list is not empty");
    
    let val_list = genesis_vals.iter().map(|v| v.address).collect();
    compare::check_val_set(val_list, output_path.clone()).unwrap();

    fs::remove_file(output_path).unwrap();
}

#[tokio::test]
async fn test_parse_json_for_validators_and_save_blob() {
    let genesis_vals = vec![]; // TODO;

    let recovery_json_path = json_path();
    let output_path = json_path().parent().unwrap().join("fork_genesis.blob");
    dbg!(&recovery_json_path);
    dbg!(&output_path);

    let recovery = read_from_recovery_file(&recovery_json_path);

    make_recovery_genesis_from_vec_legacy_recovery(
      &recovery,
      &genesis_vals,
      output_path.clone(), 
      false
    )
        .expect("ERROR: failed to create genesis from recovery file");

    assert!(output_path.exists(), "file not created");
    
    let val_list = genesis_vals.iter().map(|v| v.address).collect();
    // don't compare all users, just the validators

    compare::check_val_set(val_list, output_path.clone()).unwrap();

    
    fs::remove_file(output_path).unwrap();
}

