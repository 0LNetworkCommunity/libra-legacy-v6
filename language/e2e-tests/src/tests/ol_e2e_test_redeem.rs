// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::executor::FakeExecutor;
use crate::account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier};
use crate::redeem_setup::{redeem_txn};
use miner::delay;
use libra_types::transaction::TransactionStatus;
use libra_types::vm_error::{VMStatus, StatusCode};
use hex;

#[test]
fn submit_proofs_transaction() {
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();

    let account = Account::new_genesis_account(libra_types::on_chain_config::config_address() );
    let sequence_number = 10u64;
    let sender = AccountData::with_account(
        account,
        1_000_000,
        lbr_currency_code(),
        sequence_number,
        AccountTypeSpecifier::Empty
    );

    executor.add_account_data(&sender);

    println!("address:{:?}", sender.address() );

    // let initialization_output = executor.execute_and_apply(
    //     // TODO: Describe what is happening here. What are we initializing?
    //     redeem_initialize_txn(&sender.account(), sequence_number)
    // );
    // assert_eq!(
    //     initialization_output.status(),
    //     &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    // );

    // test data for the VDF proof
    // let challenge = b"test preimage";
    // let difficulty = 100;
    // // use a test pre image and a 100 difficulty

    let challenge = hex::decode("aa").unwrap();
    let difficulty = 100;
    // Generate solutions with cd ./verfiable-delay/ cargo run -- -l=4096 aa 100
    // the -l=4096 is important because this is the security paramater of 0L miner.
    let proof_computed = delay::do_delay(&challenge);

    let proof = hex::decode("002fb6ae7221c8593fb21599fdbee8837426761b328f76609295c9175d5f061bb29792236d22366d0d9305040661b54f59cea3f8e143a584f178981549b462bdc96a3ef270dc1457985390a3401c484b721fdd00f0330b894755d34a311c547b73065aec1a71528d0dc350c13fa68aaf34d206a5fa56f7391b889f1226d7aacc3624eca7f27d523db4f2f18e4ca0bd4cd91b4133cce16b40245d9d393a0c32013f91c5d2bfaca7e5e4c4f71ea90bdc9047657e02e7a429b3f4988b3a7f0789a6c4e0b60af26139dba0c5a83eecc785dbdde0012e47ef3af7fe60e366b8e87ac437da111c8ffb57f400980513b47db04c47787380ea564ffaf1653aa5889e5b31340022cfdd5956cf2fc9130ea4e45a700a5fbd990aae8a4643b22508b6d0b6b80186b5eea2c656296ad2d2043867bd93d48a284b90c2792aeeb25f6a7f0dacac617e7660074e18109e6675480ebc6340f4b01d74d8e5943b9bc8f9acdb3d8ebef5f593858913ebbc2f0d4b1fc76dacca4b032bb8d97e018a614e667bbbb07da891d23028b60275bc2c715e975b347c2e72e5753282959973f34742a43393d76b025b6444e4cabf4272eceae3d94a19ae1f24edf725e8892eb45f34e8a224a5ee56effa8f4b5a3a3bf810579cba99f0e954ce8459afe963bbb2c2578bd5de48e6df56a29ef03dda9e03e19c08fed8b467065afd38720f634c646698a1841c4a21037700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

    assert_eq!(proof_computed, proof.to_vec());

    let tower_height = 1u64;
    
    //run the transaction script
    let output = executor.execute_and_apply(
        // build the transaction script binary.
    redeem_txn(
        &sender.account(), 
        sequence_number,
        challenge.to_vec(),
        difficulty,
        proof.to_vec(),
        tower_height)
    );

    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );
}
