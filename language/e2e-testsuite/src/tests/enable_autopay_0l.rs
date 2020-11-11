// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
    account::{Account},
    executor::FakeExecutor
};
use libra_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
use transaction_builder::encode_minerstate_commit_script;


#[test]
fn autopay() {
  let mut executor = FakeExecutor::from_genesis_file();

  let seq_num = 1;
  let sender = Account::new_libra_root();


  let script = transaction_builder::encode_enable_autopay_script();
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