//! Tests for the `make_genesis` binary.
mod support;

use diem_crypto::ValidCryptoMaterialStringExt;
use diem_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    Uniform,
};
use diem_genesis_tool::validator_builder::ValidatorBuilder;
use diem_types::{
    account_config::BalanceResource,
    transaction::authenticator::AuthenticationKey,
    validator_config::{ValidatorConfig, ValidatorConfigResource},
};
use ol_genesis_tools::{read_snapshot, compare};
use ol_genesis_tools::{
    fork_genesis::make_recovery_genesis_from_vec_legacy_recovery,
    recover::{AccountRole, LegacyRecovery},
};
use std::fs;
use support::path_utils::json_path;
use std::num::NonZeroUsize;
use diem_crypto::PrivateKey;
use diem_types::account_address::AccountAddress;

use diem_crypto::test_utils::TEST_SEED;
use rand::rngs::StdRng;
use rand::SeedableRng;

#[test]
// test that a genesis blob created from struct, will actually contain the data
fn test_make_genesis() {
    
    // let recovery_json_path = json_path();

    let json = json_path().parent().unwrap().join("single_json_entry.json");

    let json_str = fs::read_to_string(json.clone()).unwrap();
    let mock_val: Vec<LegacyRecovery> = serde_json::from_str(&json_str).unwrap();

    // dbg!(&mock_val);

    let temp_genesis_blob_path = json_path().parent().unwrap().join("fork_genesis.blob");

    make_recovery_genesis_from_vec_legacy_recovery(mock_val, temp_genesis_blob_path.clone(), true)
    .unwrap();

    assert!(temp_genesis_blob_path.exists(), "file not created");

    let list = compare::compare_json_to_genesis_blob(json, temp_genesis_blob_path.clone());

    dbg!(&list);
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
