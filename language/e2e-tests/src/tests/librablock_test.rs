// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{self, Account, AccountData},
    // common_transactions::peer_to_peer_txn,
    common_transactions::{create_account_txn, create_validator_account_txn},
    executor::FakeExecutor,
    gas_costs, transaction_status_eq,
    librablock_setup::librablock_helper_tx,
};
use libra_types::{
    account_config::{self, ReceivedPaymentEvent, SentPaymentEvent, LBR_NAME},
    on_chain_config::VMPublishingOption,
    transaction::{
        Script, SignedTransaction, TransactionArgument, TransactionOutput, TransactionPayload,
        TransactionStatus,
    },
    vm_error::{StatusCode, VMStatus},
};
use std::{convert::TryFrom, time::Instant};
use stdlib::transaction_scripts::StdlibScript;
use vm::file_format::{Bytecode, CompiledScript};

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
