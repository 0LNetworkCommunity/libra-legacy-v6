// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier},
    // common_transactions::peer_to_peer_txn,
    executor::FakeExecutor,
    txn_fee_setup::{txn_fee_tx_mint, txn_fee_tx_distr}
};
use libra_types::transaction::TransactionStatus;
use libra_types::vm_error::{VMStatus, StatusCode};


#[test]
fn txn_fees_test () { 
    // Run with: `cargo xtest -p language-e2e-tests txn_fee_test -- --nocapture`
    let mut executor = FakeExecutor::from_genesis_file();
    let sequence_number = 1u64;

    // Need to create some account types to be able to call a tx script.
    let association_account = Account::new_association();
    let account = Account::new();

    let assoc_acc_data = AccountData::with_account(
        association_account, 1_000_000,
        lbr_currency_code(),sequence_number, AccountTypeSpecifier::Empty);
    executor.add_account_data(&assoc_acc_data);

    let acc_data = AccountData::with_account(
        account, 5_000_000,
        lbr_currency_code(),sequence_number, AccountTypeSpecifier::Empty);
    executor.add_account_data(&acc_data);

    // Construct a valid and signed tx script.
    let mint = txn_fee_tx_mint(&assoc_acc_data.account(), &acc_data.account(), 1);
    let distr = txn_fee_tx_distr(&assoc_acc_data.account(), 2);

    executor.new_block(); 
    let mut output = executor.execute_and_apply(mint);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );

    executor.new_block();
    output = executor.execute_and_apply(distr);

    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );
}
