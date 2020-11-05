// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
    account::{Account},
    executor::FakeExecutor,
    setup_0L::demo_tx,
};
use libra_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};

#[test]
fn demo() {
    let mut executor = FakeExecutor::from_genesis_file();
    // use system account
    let sender = Account::new_libra_root();

    // uses a helper in e2e test infrastructure
    let txn = demo_tx(
        &sender,
        1,
    );

    // execute transaction
    let output = executor.execute_transaction(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed)
    );
    executor.apply_write_set(output.write_set());

    // check that numbers in stored DB are correct
    // let updated_sender = executor
    //     .read_account_resource(&sender)
    //     .expect("sender must exist");

    // let updated_receiver_balance = executor
    //     .read_balance_resource(&new_account, account::coin1_tmp_currency_code())
    //     .expect("receiver balance must exist");
    // assert_eq!(initial_amount, updated_receiver_balance.coin());
    // assert_eq!(1, updated_sender.sequence_number());
}
