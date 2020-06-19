// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{self, Account, AccountData},
    // common_transactions::peer_to_peer_txn,
    executor::FakeExecutor,
    librablock_setup::librablock_helper_tx,
};


use libra_crypto::HashValue;
use libra_state_view::StateView;
use libra_types::{
    access_path::AccessPath,
    account_config::{AccountResource, BalanceResource},
    block_metadata::{new_block_event_key, BlockMetadata, NewBlockEvent},
    on_chain_config::{OnChainConfig, VMPublishingOption, ValidatorSet},
    transaction::{
        SignedTransaction, Transaction, TransactionOutput, TransactionStatus, VMValidatorResult,
    },
    vm_error::{StatusCode, VMStatus},
    write_set::WriteSet,
};

#[test]
fn librablock () { // Run with: `cargo xtest -p language-e2e-tests librablock -- --nocapture`
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();

    // meed to create some account types to be able to call a tx script.
    let association_account = Account::new_association();
    let validator_account = Account::new();

    // construct a valid and signed tx script.
    let txn = librablock_helper_tx(&association_account, &validator_account, 1);

    // TODO: force the test runner to create a new block before running the test.
    // Unclear how this works. At times it seems the executor will start fresh on the next instruction.
    executor.new_block(); // block parameters include the validators which voted on the previous block.
    // execute and persist the transaction
    executor.execute_and_apply(txn);

    // let account_state = executor
    //     .read_account_resource(&association_account)
    //     .expect("sender must exist");
    // // TODO: get a list of validators here. Test that the stats is inserting the validator votes.
    //
    // println!("history_state \n{:?}", &account_state.received_events());
}
