// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
    // account::{Account},
    executor::FakeExecutor
};
use diem_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
use transaction_builder;
use hex;
use language_e2e_tests::account::AccountData;


#[test]
fn miner_commit () {
    let mut executor = FakeExecutor::from_genesis_file();

    // test data for the VDF proof, using easy/test difficulty
    // This assumes that it is a FIRST Proof, (genesis proof)
    // and it doesn't neet to match a previously sent proof.
    // effectively only a genesis ceremony will use this transaction.
    // Other miner onboarding will be done with the onboarding transaction.

    // This test uses Alice's block_1 proof (../fixtures/block_1.json.stage.alice), assuming she has participated in a genesis ceremony.
  let preimage = hex::decode("3190cef88aa2fb86fbfa062f62be33d08d1493e982597d7be286ab5b6d01e4b0").unwrap();
  let proof = hex::decode("006e33a9542693512b59aa04081bb2a87f0bf07328c62cfc5dafdebf57c35ddd6a75664ddfa7ebfe0b9cbc6c5d19f03f77841cef9923d32bea8a4a642adfd94a31d2b523cb32e8adc27ee63ec2d793f3c224c0be2c4258dcb7ba5b74ee78d21f1d045165c9bd7e41a42085ea4cdb95fb8ffd437448ad93610d4d445f339807fffbffb3a77ab38d67e301889a7d83a789895fa5a12113213b4674ec4dbd6037bcd7c9e8c5edb6f7bf738e19845aa25c0cd3cf258f978c406195c2a8d7edf8785d1697653d213add8cb632680f167dbb1a6a4716a2b174a91c5319c9b5224504975e94e7b751b55bad30b27678fa9c46d94d02f5bf757d27305b1283c542ca02927427000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();
    // assert_eq!(proof_computed, proof.to_vec());

    //let sender = Account::new();
    let sequence = 1;
    let sender = AccountData::new(1_000_000, sequence);
    let receiver = AccountData::new(100_000, 10);
    executor.add_account_data(&sender);
    executor.add_account_data(&receiver);

    let script_help = transaction_builder::encode_minerstate_helper_script();
    let txn_help = sender.account()
        .transaction()
        .script(script_help)
        .sequence_number(sequence)
        .sign();

    let output = executor.execute_and_apply(txn_help);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed)
    );
    println!("Help executed successfully");

    let script = transaction_builder::encode_minerstate_commit_script(
        preimage,
        proof,
    );

    let txn = sender.account()
    .transaction()
    .script(script)
    .sequence_number(sequence+1)
    .sign();
    
    let output = executor.execute_transaction(txn);
    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(KeptVMStatus::Executed)
    );
}
