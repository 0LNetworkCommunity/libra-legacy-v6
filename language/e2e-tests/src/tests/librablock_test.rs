// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{self, Account, AccountData},
    // common_transactions::peer_to_peer_txn,
    executor::FakeExecutor,
    librablock_setup::librablock_helper_tx,
};

#[test]
fn librablock () {
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();
    // force the test runner to create a new block before running the test.
    executor.new_block(); // block parameters include the validators which voted on the previous block.

    // meed to create some account types to be able to call a tx script.
    let genesis_account = Account::new_association();
    let validator_account = Account::new();

    // construct a valid and signed tx script.
    let txn = librablock_helper_tx(&genesis_account, &validator_account, 1);

    // execute and persist the transaction
    executor.execute_and_apply(txn);
}
