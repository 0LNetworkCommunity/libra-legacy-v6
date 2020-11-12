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
fn miner_onboarding() {
    let mut executor = FakeExecutor::from_genesis_file();

    // test data for the VDF proof, using easy/test difficulty
    // This assumes that it is a FIRST Proof, (genesis proof)
    // and it doesn't neet to match a previously sent proof.
    // effectively only a genesis ceremony will use this transaction.
    // Other miner onboarding will be done with the onboarding transaction.

    // This test uses Alice's block_1 proof (../fixtures/block_1.json.stage.alice), assuming she has participated in a genesis ceremony.
    let preimage = hex::decode("7ccfbe11759c6a348a09ebac903c312628cf89a971e73f1e0563930ab9271c69").unwrap();
    // let proof_computed = delay::do_delay(&challenge);

    let proof = hex::decode("006408be2b99428c65d7a431a5e7a9e1657de1e8aae012274c43a744e3038a54a64cce4be427b64518b105f469d6c76eb7be7b2ee64acf5a786f2f2e7b7a3191f1c9ee0409a5780dfe9d979b48497abeab80cf985019363f83357ea64e57de3eb7c61411ea08467306ba7551317c871c8677e3af96d30fb1c33ffd5ce764e3dae4004c6930ef09561130b563b61cac4eb148a06c6d114a7531390edab64dbefeff99fd759ed32b0730a9a2a94fcb0032fc7740bab401a9af78f520150785d5093d38a020d330e875876d60e3aeaad7d10026a4a5fcc66553530b2ae6026c3ed8f3ff727cee3c0d2e96303594aa7a22df71cb8ac361ae687cc77ebae18e1b315a6e5d0001186b2b957c219389f3c4f7f3175332a0b3433ebff2f42a22d2a27b7615721d29ccded6a1a48171cb75b389cbbd5c1185d516e55578a3d0c343e643110eae5bfb244b783bc2ef394352f9c0d340df1397e594a553de0b4ae155eb1a0121ff9928f2318fa622bba08b9f9f21cc4294d58a70b5dd53b834b83fcc2f77d2729f03000001f0c19f6ee6000f09b39da694c6e1dd55bc365e298ec15fd863288565c8b0f06634d728b3e74443b5f365a3c14280795d41c921acbd67f25ee993d8fe2359545ef40191a193c2ff37df709a312573c904722753757cbbfc7b6f3c0cbfc7a21bcf72cec4bfccf640d4d93d1e4ceb54561e95b2cfaa4d964b32c7050ae097cb").unwrap();

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
    let consensus_pubkey = hex::decode("8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010").unwrap();
    let validator_network_address = "192.168.0.1".as_bytes().to_vec();
    let full_node_network_address = "192.168.0.1".as_bytes().to_vec();
    let human_name = "1ee7".as_bytes().to_vec();

    let script = transaction_builder::encode_minerstate_onboarding_script(
        preimage,
        proof,
        consensus_pubkey,
        validator_network_address,
        full_node_network_address,
        human_name,
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

// use crate::executor::FakeExecutor;
// use crate::account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier};
// use crate::setup_0L::{e2e_submit_proof_txn, e2e_miner_state_fixtures};
// use miner::delay;
// use libra_types::transaction::TransactionStatus;
// use libra_types::vm_error::{VMStatus, StatusCode};
// use move_core_types::account_address::AccountAddress;
// use hex;

// #[test]
// fn submit_proofs_steady() {
//     let mut executor = FakeExecutor::from_genesis_file();

//     let old_miner = AccountAddress::from_hex_literal( &"0x00000000000000000000000000001337").unwrap();

//     let account = Account::new_genesis_account(old_miner);
//     // let account = Account::new();
//     let sequence_number = 10u64;
//     let sender = AccountData::with_account(
//         account,
//         1_000_000,
//         lbr_currency_code(),
//         sequence_number,
//         AccountTypeSpecifier::Empty
//     );

//     executor.add_account_data(&sender);

//     // test data for the VDF proof, using easy/test difficulty
//     // This assumes that it is a FIRST Proof, (genesis proof)
//     // and it doesn't neet to match a previously sent proof.
//     // effectively only a genesis ceremony will use this transaction.
//     // Other miner onboarding will be done with the onboarding transaction.

//     // This test uses Alice's block_1 proof (../fixtures/block_1.json.stage.alice), assuming she has participated in a genesis ceremony.
//     let challenge = hex::decode("a3964fe3be43749e77b87f30d38cb8b18b689c7e4008ddcf3543af06f2ef2cd0").unwrap();
//     let proof_computed = delay::do_delay(&challenge);

//     let proof = hex::decode("001ad2af3d252dd7a54aec500cb51c151eed01e27dd3f8aa7021568abdc0d7600f24f516ba02a034dd1cabc6da747017c7e673d46e5347d6389c09967a7be719e818f454a2c2d9347b49394ab5efec2365d428bf97a5156f698ee019edd2a8483b4c2c839e831f9a5ac8d059a48c807d561fe893b5181c9ffa34e7bd4acdb60f09a3178a20f3f95c735bb47bfcdc1e9f05a4e16e1912de56f8aa97d4501c6dd8214cf6c3e716da7cae5874e8deb18546da3e653ef0337f25c2b329fcb69a181fa2ee5cac249d2c363f6e2da083bd1bb3d447a338cfaae0da8b30a57f749ed95ce57b5f2cc4426ecc5ed3e850a5947e1d6eddc72c863ce9183bfafe22a2399c2e6800088044be8bf013bcc072f25358db9ce770df965916db04799e957a1789bb7f8f6cdf5603228452cc872aaa601a5e769c88f750ab211758ab8051dcf012b65bfaaf1b40f01969dea081e198f984f2452a705dd98a66893b23fc3a4d15e60c158e63f4286f9b137dd48cf000dbb9b85f2f52405874f909bbc620882cfb8884743cd5bdfbf027acdabc4ec342b33e4ab01c8b4ab9b6a58cdc9aac6a515f251e0b6021ac150fe17be67f89e1779f91f4625e8e28e4975b42a9179e9fe2dc07feb5ad57c16bbb0886c70f7d298feb170705499b64fdeba3307e187b56776f3281e970993dbfcdca7ef0a58a3ddb8f58ed0c095f8b1f433191a2b75b278f8f4f7b161500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

//     assert_eq!(proof_computed, proof.to_vec());
    
//     let setup = executor.execute_and_apply(
//         e2e_miner_state_fixtures(
//             &sender.account(), 
//             sequence_number,
//             )
//     );

//     assert_eq!(
//         setup.status(),
//         &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
//     );
//     // run the transaction script
//     let output = executor.execute_and_apply(
//         // build the transaction script binary.
//         e2e_submit_proof_txn(
//         &sender.account(), 
//         sequence_number + 1,
//         challenge.to_vec(),
//         proof.to_vec(),
//         0,
//         )
//     );

//     assert_eq!(
//         output.status(),
//         &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
//     );
// }


