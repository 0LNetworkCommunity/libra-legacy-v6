// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
    account::{Account},
    executor::FakeExecutor
};
use libra_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
use transaction_builder;


#[test]
fn trusted() {
    let mut executor = FakeExecutor::from_genesis_file();
    // use system account
    let sender = Account::new_libra_root();
    let seq_num = 1;

    let new_account_address = *Account::new().address();
    let new_account_address_two = *Account::new().address();

    let vec_address = vec![new_account_address, new_account_address_two];
    let script = transaction_builder::encode_update_trusted_script(vec_address.clone(), vec_address);
    let txn = sender
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