
use crate::{
    account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier},
    common_transactions::{create_validator_account_txn, register_validator_txn},
    executor::FakeExecutor,
    transaction_status_eq,
    reconfig_setup::{bulk_update, bulk_update_setup}
};
use libra_types::{
    account_config::lbr_type_tag,
    transaction::TransactionStatus,
    vm_error::{StatusCode, VMStatus},
};
use std::convert::TryInto;
use transaction_builder::*;

#[test]
fn reconfig_bulk_update_test () {
    // Run with: `cargo xtest -p language-e2e-tests reconfig_bulk_update_test -- --nocapture`
    let mut executor = FakeExecutor::from_genesis_file();
    let sequence_number = 1u64;

    // NOTE: While true that the VM will initialize with some validators, this 
    // test involving checking the size and members of the validator set in move.
    // So, even though there are some validators already created, this test is 
    // run with five new validators.

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

    // Create a transaction allowing the accounts to serve as validators
    for i in 0..5 {
        let txn = create_validator_account_txn(&assoc_acc_data.account(), accounts.get(i).unwrap(), (i + 1).try_into().unwrap());
        executor.execute_and_apply(txn);
    }

    // Give the validators some money
    let mint_amount = 10_000_000;
    for i in 0..5 {
        executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
            encode_mint_script(lbr_type_tag(), accounts.get(i).unwrap().address(), vec![], mint_amount),
            (i + 6).try_into().unwrap(),
        ));
    }
    executor.new_block();

    // Actually register the accounts as validators
    for i in 0..5 {
        let txn = register_validator_txn(accounts.get(i).unwrap(), vec![255; 32], vec![254; 32], vec![],
            vec![253; 32], vec![], 0);
        executor.execute_and_apply(txn);
        executor.new_block();
    }

    // Construct the signed tx script for test setup.
    // This removes default validators and adds ours instead.
    let setup = bulk_update_setup(&assoc_acc_data.account(), &accounts, 11);

    // Execute and persist the txn in a new block
    executor.new_block();
    let tx_out = executor.execute_and_apply(setup);

    // Assert success
    assert!(transaction_status_eq(
        &tx_out.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    ));

    // Construct a valid and signed tx script.
    let bulk_update = bulk_update(&assoc_acc_data.account(), &accounts, 12);
    
    // Execute and persist the txn in a new block
    executor.new_block();
    let tx_out = executor.execute_and_apply(bulk_update);

    // Assert success
    assert!(transaction_status_eq(
        &tx_out.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    ));
}
