// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::Account,
    // common_transactions::peer_to_peer_txn,
    executor::FakeExecutor,
    librablock_setup::librablock_helper_tx,
};
use libra_types::transaction::TransactionStatus;
use libra_types::vm_error::{VMStatus, StatusCode};

#[test]
fn librablock() {
    // Run with: `cargo xtest -p language-e2e-tests librablock -- --nocapture`
    let mut executor = FakeExecutor::from_genesis_file();

    // Need to create some account types to be able to call a txn script.
    let association_account = Account::new_association();

    // Construct a valid and signed tx script.
    let txn = librablock_helper_tx(&association_account, 1);

    // Force the test runner to create a new block before running the test.
    executor.new_block();
    
    // Execute and persist the transaction
    let output = executor.execute_and_apply(txn);

    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );
}
