// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
  account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier},
  common_transactions::{create_validator_account_txn, register_validator_txn},
  executor::FakeExecutor,
  oracle_setup::{oracle_helper_tx, upgrade_foo_tx},
  transaction_status_eq,
  reconfig_setup::bulk_update_setup,
};
use libra_types::{
  transaction::TransactionStatus,
  vm_status::{VMStatus, StatusCode},
  on_chain_config::VMPublishingOption,
  account_config::lbr_type_tag,
};
use transaction_builder::encode_mint_script;

fn set_up_validators(
  executor : &mut FakeExecutor, 
  association_account: Account, 
) -> Vec<Account> {
  // creates five validator accounts
  let mut accounts = vec![];
  for _i in 0..5 {
      accounts.push(Account::new());
  }

  // Add the account datas
  let mut sequence_number = 1u64;
  let assoc_acc_data = AccountData::with_account(
      association_account, 1_000_000_000,
      lbr_currency_code(),*&sequence_number, AccountTypeSpecifier::Empty);
  executor.add_account_data(&assoc_acc_data);

  // Create a transaction allowing the accounts to serve as validators
  for i in 0..5 {
      let txn = create_validator_account_txn(&assoc_acc_data.account(), accounts.get(i).unwrap(), *&sequence_number);
      sequence_number += 1;
      executor.execute_and_apply(txn);
  }

  // Give the validators some money
  let mint_amount = 10_000_000_000; // Oversized upgrade payload
  for i in 0..5 {
      executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
          encode_mint_script(lbr_type_tag(), accounts.get(i).unwrap().address(), vec![], mint_amount),
          *&sequence_number,
      ));
      sequence_number += 1;
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
  let setup = bulk_update_setup(&assoc_acc_data.account(), &accounts, *&sequence_number);

  // Execute and persist the txn in a new block
  executor.new_block();
  let tx_out = executor.execute_and_apply(setup);

  // Assert success
  assert!(transaction_status_eq(
      &tx_out.status(),
      &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
  ));

  accounts
}

// hardcoding a sender with seq_num = 1
fn test_foo (sender: &Account, executor: &mut FakeExecutor, should_pass: bool) {
  // Construct a valid and signed tx script.
  let txn = upgrade_foo_tx(sender, 1);

  // Force the test runner to create a new block before running the test.
  executor.new_custom_block(2);
  
  let output = &executor.execute_transaction(txn);
  if should_pass {
      assert_eq!(
          output.status(),
          &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
      );
  } else {
      assert_eq!(
          output.status().vm_status().major_status,
          StatusCode::LOOKUP_FAILED
      );
  };
}

#[test]
fn test_single_oracle_tx() {
  // Run with: `cargo xtest -p language-e2e-tests test_single_oracle_tx -- --nocapture`
  let mut executor = FakeExecutor::from_genesis_with_options(VMPublishingOption::Open);

  // create an association account and validator accounts
  let association_account = Account::new_association();
  let accounts = set_up_validators(&mut executor, association_account);

  // Construct a valid and signed tx script.
  let txn = oracle_helper_tx(&accounts.get(0).unwrap(), 1);

  // Force the test runner to create a new block before running the test.
  executor.new_custom_block(2);
  
  // Execute and persist the transaction
  let output = executor.execute_and_apply(txn);

  assert_eq!(
      output.status(),
      &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
  );

  // verify that the foo transaction should fail
  test_foo(&accounts.get(1).unwrap(), &mut executor, false);
}

#[test]
fn test_validators_oracle_tx() {
  // Run with: `cargo xtest -p language-e2e-tests test_validators_oracle_tx -- --nocapture`
  let mut executor = FakeExecutor::from_genesis_with_options(VMPublishingOption::Open);

  // create an association account and validator accounts
  let association_account = Account::new_association();
  let accounts = set_up_validators(&mut executor, association_account);

  executor.new_custom_block(2);

  // Construct a valid and signed tx script.
  let txn_0 = oracle_helper_tx(&accounts.get(0).unwrap(), 1);
  let output = executor.execute_and_apply(txn_0);
  assert_eq!(
      output.status(),
      &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
  );

  executor.new_custom_block(2);
  let txn_1 = oracle_helper_tx(&accounts.get(1).unwrap(), 1);
  let output = executor.execute_and_apply(txn_1);
  assert_eq!(
      output.status(),
      &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
  );

  executor.new_custom_block(2);
  let txn_2 = oracle_helper_tx(&accounts.get(2).unwrap(), 1);
  let output = executor.execute_and_apply(txn_2);
  assert_eq!(
      output.status(),
      &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
  );

  // verify that the foo transaction should fail
  test_foo(&accounts.get(3).unwrap(), &mut executor, false);

  // The creation of these blocks update the stdlib
  executor.new_custom_block(2);
  executor.new_custom_block(2);

  // verify that the foo transaction should pass with the updated stdlib
  test_foo(&accounts.get(4).unwrap(), &mut executor, true);

  // Checks update doesn't happen again
  executor.new_custom_block(2);
}
