// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0
use language_e2e_tests::{account::AccountData, executor::FakeExecutor};
use diem_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
// use transaction_builder;
use diem_transaction_builder::stdlib as transaction_builder;
// use diem_framework_releases::legacy::transaction_scripts as transaction_builder;

#[test]
fn autopay_enable_test() {
  let mut executor = FakeExecutor::from_genesis_file();

  let sender = AccountData::new(1_000_000, 1);
  executor.add_account_data(&sender);
  let seq_num = 1;
  let payload = transaction_builder::encode_autopay_enable_script_function();
  let txn = sender.into_account()
    .transaction()
    .payload(payload)
    .sequence_number(seq_num)
    .sign();

  // execute transaction
  let output = executor.execute_transaction(txn);
  assert_eq!(
    output.status(),
    &TransactionStatus::Keep(KeptVMStatus::Executed)
  );
  executor.apply_write_set(output.write_set());
}