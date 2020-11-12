// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
    // account::{Account},
    executor::FakeExecutor
};
use libra_types::{transaction::TransactionStatus, vm_status::KeptVMStatus};
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
    let preimage = hex::decode("c3de80a6d29ee233e8d12ff2bf65c67d0306ea16b46720dfa0829fa85e900701").unwrap();
    // let proof_computed = delay::do_delay(&challenge);

    let proof = hex::decode("003b75d7f51101287bf2d6ac7ac8d1169a0e89f4bc5cebe36c612c6e6aab557ca2083cdf477f856657e62a6a1e2e26ed40521198e74cb7babeeb86e94ea1dd03388d3c9296a9cd073389fe09331ac59d085bfb78b5e52fc20d4df27f8f63853dd4ecfeee230e9aa4615433f8fcb783dd03d689c284575cf082a1783e99a44379de002ff2ea1f1e8915dc6b631ba6ce102542632df5f91320f4bc95e786e0d7c08d727245597da98d1b363750483897e859396b40b0b2a54a000a10a4000ddea250f667f8a782aa26bbc7490deb6efcf2af36749d55118e4122d904fc928f1fd256ea744316169b4f01c06094c133088b12e5f5fd692dce51124f3cab2206bda00355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

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
