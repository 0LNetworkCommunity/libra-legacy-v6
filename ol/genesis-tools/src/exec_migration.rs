
//! Using the e2e test helpers we create a MoveVm session from fake data to be able to apply migrations
//! from Move system contracts. i.e. we don't craft the writesets
//! manually in rust, instead we execute functions in a Move session.

use diem_types::{write_set::WriteSet, account_config};
use language_e2e_tests::executor::FakeExecutor;
use move_core_types::value::{MoveValue, serialize_values};

use crate::recover::LegacyRecovery;

/// creates an executor vm session to create writesets
pub fn create_session(ws: &WriteSet, _rec: LegacyRecovery) {

    let mut executor = FakeExecutor::from_genesis(ws);
    let output = executor.try_exec(
        "Diem",
        "initialize",
        vec![],
        serialize_values(&vec![
            MoveValue::Signer(account_config::diem_root_address()),
        ]),
    );

    assert_eq!(output.unwrap_err().move_abort_code(), None);
}

