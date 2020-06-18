// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{self, Account, AccountData},
    // common_transactions::peer_to_peer_txn,
    common_transactions::create_account_txn,
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
fn librablock() {
    // create a FakeExecutor with a genesis from file
    let mut executor = FakeExecutor::from_genesis_file();
    let sender = AccountData::new(1_000_000, 10);
    executor.add_account_data(&sender);
    let new_account = Account::new();
    let initial_amount = 1_000;
    let txn = create_account_txn(sender.account(), &new_account, 10, initial_amount);

    // executor.add_account_data(&sender);
    // let new_account = Account::new();
    // let initial_amount = 1_000;
    // let (txns_info, txns) = create_cyclic_transfers(&executor, &accounts, transfer_amount);
    let txn = librablock_helper_tx(
        &new_account, //sender: &Account,
        &new_account, // receiver: &Account,
        111, // seq_num: u64,
        1000, //transfer_amount: u64,
    );

    // execute transaction
    let mut execution_time = 0u128;
    let now = Instant::now();
    let output = executor.execute_and_apply(txn);
    execution_time += now.elapsed().as_nanos();
    println!("EXECUTION TIME: {}", execution_time);
    // for txn_output in &output {
    //     assert_eq!(
    //         txn_output.status(),
    //         &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    //     );
    // }
    // assert_eq!(accounts.len(), output.len());

    // check_and_apply_transfer_output(&mut executor, &txns_info, &output);
    // print_accounts(&executor, &accounts);
}
