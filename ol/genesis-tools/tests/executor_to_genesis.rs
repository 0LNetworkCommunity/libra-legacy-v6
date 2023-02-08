//! Tests for the `make_genesis` binary.
mod support;

use diem_types::transaction::Transaction;
use language_e2e_tests::data_store::GENESIS_CHANGE_SET_FRESH;
use move_core_types::language_storage::TypeTag;
use move_core_types::value::MoveValue;
use ol_genesis_tools::exec_migration;
use ol_genesis_tools::recover::LegacyRecovery;
use std::fs;
use support::path_utils::json_path;
use diem_types::transaction::WriteSetPayload;
#[test]
#[ignore]
// test that a genesis blob created from struct, will actually contain the data
fn test_use_vm_session() {

    let json = json_path().parent().unwrap().join("single_json_entry.json");

    let json_str = fs::read_to_string(json.clone()).unwrap();
    let mock_val: Vec<LegacyRecovery> = serde_json::from_str(&json_str).unwrap();

    let genesis_baseline = GENESIS_CHANGE_SET_FRESH.write_set().clone();
    let out = exec_migration::start_vm_and_transform(
      &genesis_baseline,
      mock_val,
      false,
      "Debug",
      "print",
      Some(vec![TypeTag::U64]),
      no_op,
    ).unwrap();

    let merge = genesis_baseline.into_mut().extend(out.into_mut().get()).freeze().unwrap();

    // let gen_tx = Transaction::GenesisTransaction(WriteSetPayload::Direct(merge));

    // let temp_genesis_blob_path = json_path().parent().unwrap().join("fork_genesis.blob");

    // save_genesis(gen_tx, genestemp_genesis_blob_pathis_blob_path);


    // make_recovery_genesis_from_vec_legacy_recovery(mock_val, temp_genesis_blob_path.clone(), true)
    //     .unwrap();

    // assert!(temp_genesis_blob_path.exists(), "file not created");

    // let list = compare::compare_json_to_genesis_blob(json, temp_genesis_blob_path.clone());

    // dbg!(&list);
    // assert!(list.expect("no list").len() == 0, "list is not empty");
    // fs::remove_file(temp_genesis_blob_path).unwrap();
}


fn no_op(_l: &LegacyRecovery) -> Vec<MoveValue> {
  vec![MoveValue::U64(42)]
}