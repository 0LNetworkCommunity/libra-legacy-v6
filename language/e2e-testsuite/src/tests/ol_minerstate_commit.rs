// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
use hex;
use language_e2e_tests::{account::AccountData, executor::FakeExecutor};

#[test]
fn miner_commit () {
    let mut executor = FakeExecutor::from_genesis_file();

    // test data for the VDF proof, using easy/test difficulty
    // This assumes that it is a FIRST Proof, (genesis proof)
    // and it doesn't neet to match a previously sent proof.
    // effectively only a genesis ceremony will use this transaction.
    // Other miner onboarding will be done with the onboarding transaction.

    // This test uses Alice's block_1 proof (../fixtures/block_1.json.stage.alice), assuming she has participated in a genesis ceremony.
    let preimage = hex::decode(
        "19b7be4956ca7cb08a981ce38c30afd5a3f9699d716b606e447c32daa06d9074"
    ).unwrap();
    let proof = hex::decode(
        "002b1970e1ccc00707639ad5bd5228e61567074043a0c897563c10249580abd776ffdc2e76b8d49d2d639ef5544bdb713abab00d74490e7759788d0c6bf6df6be59d"
    ).unwrap();
    // assert_eq!(proof_computed, proof.to_vec());

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

    let payload = transaction_builder::encode_minerstate_commit_script_function(
        preimage,
        proof,
        100,
        2048,
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
