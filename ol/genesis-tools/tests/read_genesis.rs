mod support;

use support::{path_utils::blob_path, db_utils::read_db_and_compute_genesis};

use diem_types::account_address::AccountAddress;
use diem_types::{
    account_state::AccountState, on_chain_config::ValidatorSet
};
use std::convert::TryFrom;
// use std::path::PathBuf;
// use storage_interface::{DbReaderWriter};


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

    let validator_set: ValidatorSet = account_state
        .get_validator_set()
        .unwrap()
        .unwrap();
    
    assert_eq!(135, validator_set.payload().len());
}
