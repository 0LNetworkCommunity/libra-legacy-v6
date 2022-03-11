// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{account::AccountData, executor::FakeExecutor};
use diem_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
use diem_transaction_builder::stdlib as transaction_builder;

#[test]
fn demo() {
    // use system account
    let sender = AccountData::new(1_000_000, 1);
    let mut executor = FakeExecutor::from_genesis_file();
    executor.add_account_data(&sender);
    let seq_num = 1;
    let hello_world= 100u64;
    let payload = transaction_builder::encode_demo_e2e_script_function(hello_world);
    let txn = sender.into_account()
        .transaction()
        .payload(payload)
        .sequence_number(seq_num)
        .sign();

    let output = executor.execute_transaction(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed)
    );
    executor.apply_write_set(output.write_set());
}