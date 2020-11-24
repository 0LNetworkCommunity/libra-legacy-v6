// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{account::AccountData, executor::FakeExecutor};
use libra_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
use transaction_builder;


#[test]
fn demo() {
    let mut executor = FakeExecutor::from_genesis_file();
    // use system account
    let sender = AccountData::new(1_000_000, 1);
    executor.add_account_data(&sender);
    let seq_num = 1;
    let hello_world= 100u64;
    let script = transaction_builder::encode_demo_e2e_script(hello_world);
    let txn = sender.into_account()
        .transaction()
        .script(script)
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