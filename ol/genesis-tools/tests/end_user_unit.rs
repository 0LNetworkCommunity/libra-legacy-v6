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
fn test_end_user_migrate() {

  let genesis_vals = vec!["ADCB1D42A46292AE89E938BD982F2867".parse().unwrap()];

  let json = json_path().parent().unwrap().join("single_json_entry.json");

  let json_str = fs::read_to_string(json.clone()).unwrap();
  let mut val_accounts: Vec<LegacyRecovery> = serde_json::from_str(&json_str).unwrap();

  let json = json_path().parent().unwrap().join("sample_end_user_single.json");

  let json_str = fs::read_to_string(json.clone()).unwrap();
  let mut user_accounts: Vec<LegacyRecovery> = serde_json::from_str(&json_str).unwrap();
  
  val_accounts.append(&mut user_accounts);
  

    // dbg!(&mock_val);

    let temp_genesis_blob_path = json_path().parent().unwrap().join("fork_genesis.blob");

    make_recovery_genesis_from_vec_legacy_recovery(
      &val_accounts,
      genesis_vals.clone(),
      temp_genesis_blob_path.clone(), 
      true,
      // TODO: add validators
    )
    .unwrap();

    assert!(temp_genesis_blob_path.exists(), "file not created");

    let list = compare::compare_recovery_vec_to_genesis_blob(&val_accounts, temp_genesis_blob_path.clone());

    dbg!(&list);
    assert!(list.expect("no list").len() == 0, "list is not empty");
    
    compare::check_val_set(genesis_vals, temp_genesis_blob_path.clone()).unwrap();

    fs::remove_file(temp_genesis_blob_path).unwrap();
}

// fn public_key() -> Ed25519PublicKey {
//     let mut rng = StdRng::from_seed(TEST_SEED);
//     let pri = Ed25519PrivateKey::generate(&mut rng);
//     pri.public_key()
// }

// fn mock_valconfig() -> ValidatorConfigResource {
//     let rng = StdRng::from_seed(TEST_SEED);

//     let (root_keys, genesis, genesis_waypoint, validators) = ValidatorBuilder::new(
//         &json_path().parent().unwrap().join("temp_swarm"),
//         diem_framework_releases::current_module_blobs().to_vec(),
//     )
//     .num_validators(NonZeroUsize::new(1).unwrap())
//     .build(rng).unwrap();

//     let v = validators.first().unwrap();
//     let val_cfg = ValidatorConfig {
//         consensus_public_key: v.config,
//         validator_network_addresses: todo!(),
//         fullnode_network_addresses: todo!(),
//     };

//     ValidatorConfigResource {
//         validator_config: Some(val_cfg),
//         delegated_account: Some(val_cfg.account_address()),
//         human_name: b"d".to_vec(),
//       }
// }
