mod support;
// read_db_and_compute_genesis

use ol_genesis_tools::compare;
use ol_genesis_tools::db_utils::read_db_and_compute_genesis;

use diem_types::account_address::AccountAddress;
use diem_types::{account_state::AccountState, on_chain_config::ValidatorSet};
use std::convert::TryFrom;
use support::path_utils::{json_path, blob_path};


#[test]
fn test_compare() {
    let j = json_path();
    let b = blob_path();

    let list = compare::compare_json_to_genesis_blob(j, b);

    assert_eq!(list.unwrap().len(), 0);
}

#[test]
// #[ignore = "not sure what this was testing"]
// start a db from a genesis file created by this tool
//  and read some properties
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

    // in our tests we are only initializing the validator set
    // with 4 test validators
    assert_eq!(4, validator_set.payload().len());

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