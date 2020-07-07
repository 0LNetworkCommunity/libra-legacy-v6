// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier},
    common_transactions::{create_validator_account_txn, register_validator_txn},
    executor::FakeExecutor,
    transaction_status_eq,
    reconfig_setup::{bulk_update}
};
use libra_types::{
    account_config::lbr_type_tag,
    transaction::TransactionStatus,
    vm_error::{StatusCode, VMStatus},
};
use std::convert::TryInto;
use transaction_builder::*;

#[test]
fn reconfig_bulk_update_test () { // Run with: `cargo xtest -p language-e2e-tests reconfig_bulk_update_test -- --nocapture`
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();
    let sequence_number = 1u64;

    // Create some account types to be able to call a tx script and be validators
    let association_account = Account::new_association();
    let mut accounts = vec![];
    for _i in 0..5 {
        accounts.push(Account::new());
    }

    // Add the account datas
    let assoc_acc_data = AccountData::with_account(
        association_account, 1_000_000,
        lbr_currency_code(),sequence_number, AccountTypeSpecifier::Empty);
    executor.add_account_data(&assoc_acc_data);

    // register the accounts as validators
    for i in 0..5 {
        let txn = create_validator_account_txn(&assoc_acc_data.account(), accounts.get(i).unwrap(), (i + 1).try_into().unwrap());
        executor.execute_and_apply(txn);
    }

    // give the validators some money
    let mint_amount = 10_000_000;
    for i in 0..5 {
        executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
            encode_mint_script(lbr_type_tag(), accounts.get(i).unwrap().address(), vec![], mint_amount),
            (i + 6).try_into().unwrap(),
        ));
    }
    executor.new_block();

    for i in 0..5 {
        let txn = register_validator_txn(accounts.get(i).unwrap(), vec![255; 32], vec![254; 32], vec![], 
            vec![253; 32], vec![], 0);
        executor.execute_and_apply(txn);
        executor.new_block();
    }
    
    // construct a valid and signed tx script.
    let bulk_update = bulk_update(&assoc_acc_data.account(), &accounts, 11);
    // let distr = txn_fee_tx_distr(&assoc_acc_data.account(), 2);

    executor.new_block(); 
    let tx_out = executor.execute_and_apply(bulk_update);

    assert!(transaction_status_eq(
        &tx_out.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    ));

    // println!("gas used: {:?}, running second", tx_out.gas_used());
    // executor.new_block();
    // tx_out = executor.execute_and_apply(calc);

    // println!("gas used: {:?}, running third", tx_out.gas_used());
    // executor.new_block();
    // tx_out = executor.execute_and_apply(distr);
    // println!("gas used: {:?}", tx_out.gas_used());
}
