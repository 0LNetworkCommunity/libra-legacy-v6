// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{data_store::GENESIS_CHANGE_SET, executor::FakeExecutor};
use libra_types::transaction::{Transaction, TransactionPayload};

use stdlib::{transaction_scripts::StdlibScript, StdLibOptions};

#[test]
fn execute_genesis_write_set() {
    let executor = FakeExecutor::no_genesis();
    let txn = Transaction::WaypointWriteSet(GENESIS_CHANGE_SET.clone());
    let mut output = executor.execute_transaction_block(vec![txn]).unwrap();

    // Executing the genesis transaction should succeed
    assert_eq!(output.len(), 1);
    assert!(!output.pop().unwrap().status().is_discarded())
}

#[test]
fn execute_genesis_stdlib() {
    let executor = FakeExecutor::no_genesis();
    //let txn = Transaction::WaypointWriteSet(GENESIS_CHANGE_SET.clone());
    let txn = Transaction::WaypointWriteSet(
        transaction_builder::encode_stdlib_upgrade_transaction(StdLibOptions::Fresh)
    );
    let mut output = executor.execute_transaction_block(vec![txn]).unwrap();

    // Executing the genesis transaction should succeed
    assert_eq!(output.len(), 1);
    assert!(!output.pop().unwrap().status().is_discarded())
}