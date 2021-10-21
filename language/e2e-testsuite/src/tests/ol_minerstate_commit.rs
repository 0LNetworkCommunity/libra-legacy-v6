// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
use language_e2e_tests::{account::AccountData, executor::FakeExecutor};
use ol_types::fixtures;

#[test]
fn miner_commit () {
    let mut executor = FakeExecutor::from_genesis_file();


    //let sender = Account::new();
    let sequence = 1;
    let sender = AccountData::new(1_000_000, sequence);
    let receiver = AccountData::new(100_000, 10);
    executor.add_account_data(&sender);
    executor.add_account_data(&receiver);

    let payload = transaction_builder::encode_minerstate_helper_script_function();
    let txn_help = sender.account()
        .transaction()
        .payload(payload)
        .sequence_number(sequence)
        .sign();

    let output = executor.execute_and_apply(txn_help);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed)
    );
    println!("Help executed successfully");

    // Fixture data for the VDF proof, using easy/test difficulty
    // This assumes that it is a proof_1.json a SUBSEQUENT proof, to an already committed genesis proof.
    
    // This test uses Alice's block_1 proof (../fixtures/block_1.json.stage.alice), assuming she has participated in a genesis ceremony.

    let block = fixtures::get_persona_block_one("alice", "test");
    let payload = transaction_builder::encode_minerstate_commit_script_function(
        block.preimage,
        block.proof,
        block.difficulty.unwrap(),
        block.security.unwrap().into(),
    );

    let txn = sender.account()
        .transaction()
        .payload(payload)
        .sequence_number(sequence+1)
        .sign();
    
    let output = executor.execute_transaction(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed)
    );
}
