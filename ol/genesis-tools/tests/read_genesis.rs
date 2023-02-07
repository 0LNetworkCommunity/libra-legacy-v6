mod support;
// read_db_and_compute_genesis

use ol_genesis_tools::compare;
use ol_genesis_tools::db_utils::read_db_and_compute_genesis;

use diem_types::account_address::AccountAddress;
use diem_types::{account_state::AccountState, on_chain_config::ValidatorSet};
use std::convert::TryFrom;
use support::path_utils::{blob_path, json_path};

#[test]
// A meta test, to see if db reading works as expected.
fn test_extract_waypoint() {
    let p = blob_path();

    let (_db, wp) = read_db_and_compute_genesis(p).expect("parse genesis.blob");
    dbg!(&wp.to_string());
    assert!(wp.to_string().starts_with("0:027c"));
}

#[test]
// read db.
fn test_read_db() {
    let p = blob_path();
    let (db, _wp) = read_db_and_compute_genesis(p).expect("parse genesis.blob");

    let state = db
        .reader
        .get_latest_account_state(AccountAddress::ZERO)
        .expect("get account state")
        .expect("option is None");

    let account_state = AccountState::try_from(&state).unwrap();

    let validator_set: ValidatorSet = account_state.get_validator_set().unwrap().unwrap();

    assert_eq!(135, validator_set.payload().len());

    let acc = validator_set.payload().first().unwrap().account_address();

    let val_state = db
        .reader
        .get_latest_account_state(acc.to_owned())
        .expect("get account state")
        .expect("option is None");

    let account_state = AccountState::try_from(&val_state).unwrap();

    let bal = account_state.get_balance_resources().unwrap();

    assert!(
        bal.iter().next().unwrap().1.coin() > 0,
        "balance is not greater than 0"
    );
}

#[test]
fn test_compare() {
    let j = json_path();
    let b = blob_path();

    let list = compare::compare_json_to_genesis_blob(j, b);

    assert_eq!(list.unwrap().len(), 0);
}

// TODO: We need a way to get arbitrary Move resources extracted from an account blob.
// We should be able to get an arbitrary resource from DiemDB with ResourceResolver, but it's not clear how to do that from a DbReader instance.

// impl ResourceResolver for DiemDB {
//     type Error = anyhow::Error;

//     fn get_resource(&self, address: &AccountAddress, tag: &StructTag) -> Result<Option<Vec<u8>>> {
//         let (account_state_with_proof, _) =
//             self.get_account_state_with_proof_by_version(*address, self.get_latest_version()?)?;
//         if let Some(account_state_blob) = account_state_with_proof {
//             let account_state = AccountState::try_from(&account_state_blob)?;
//             Ok(account_state.get(&tag.access_vector()).cloned())
//         } else {
//             Ok(None)
//         }
//     }
// }
