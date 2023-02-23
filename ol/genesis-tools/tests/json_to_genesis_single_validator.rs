//! Tests for the `make_genesis` binary.
mod support;

use ol_genesis_tools::compare;
use ol_genesis_tools::{
    fork_genesis::make_recovery_genesis_from_vec_legacy_recovery
};
use ol_types::legacy_recovery::LegacyRecovery;
use std::fs;
use support::path_utils::json_path;

#[test]
// test that a genesis blob created from struct, will actually contain the data
fn test_parse_json_for_one_validator_and_save_blob() {

  let genesis_vals = vec!["ADCB1D42A46292AE89E938BD982F2867".parse().unwrap()];

    let json = json_path().parent().unwrap().join("single_json_entry.json");

    let json_str = fs::read_to_string(json.clone()).unwrap();
    let user_accounts: Vec<LegacyRecovery> = serde_json::from_str(&json_str).unwrap();

    // dbg!(&mock_val);

    let temp_genesis_blob_path = json_path().parent().unwrap().join("fork_genesis.blob");

    make_recovery_genesis_from_vec_legacy_recovery(
      &user_accounts,
      genesis_vals.clone(),
      temp_genesis_blob_path.clone(), 
      true,
    )
    .unwrap();

    assert!(temp_genesis_blob_path.exists(), "file not created");

        match compare::compare_json_to_genesis_blob(json, temp_genesis_blob_path.clone()){
        Ok(list) => {
          if !list.is_empty() {
            println!("{:?}", &list);
            fs::remove_file(&temp_genesis_blob_path).unwrap();
            assert!(false, "list is not empty");
          }
        },
        Err(_e) => assert!(false, "error comparison"),
    }

    match compare::check_val_set(genesis_vals, temp_genesis_blob_path.clone()){
        Ok(_) => {},
        Err(_) => {
          assert!(false, "validator set not correct");
          fs::remove_file(&temp_genesis_blob_path).unwrap()
        },
    }

    fs::remove_file(temp_genesis_blob_path).unwrap();
}
