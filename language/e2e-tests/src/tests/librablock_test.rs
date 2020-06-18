// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{self, Account, AccountData},
    // common_transactions::peer_to_peer_txn,
    common_transactions::{create_account_txn, create_validator_account_txn},
    executor::FakeExecutor,
    gas_costs, transaction_status_eq,
    librablock_setup::librablock_helper_tx,
};
use libra_types::{
    account_config::{self, ReceivedPaymentEvent, SentPaymentEvent, LBR_NAME},
    on_chain_config::VMPublishingOption,
    transaction::{
        Script, SignedTransaction, TransactionArgument, TransactionOutput, TransactionPayload,
        TransactionStatus,
    },
    vm_error::{StatusCode, VMStatus},
};
use std::{convert::TryFrom, time::Instant};
use stdlib::transaction_scripts::StdlibScript;
use vm::file_format::{Bytecode, CompiledScript};

// #[test] #[ignore]
// fn depr() {
//     // create a FakeExecutor with a genesis from file
//     let mut executor = FakeExecutor::from_genesis_file();
//     // create and publish a sender with 1_000_000 coins
//     let sender = AccountData::new(1_000_000, 10);
//     executor.add_account_data(&sender);
//     let new_account = Account::new();
//     let initial_amount = 1_000;
//     let txn = create_account_txn(sender.account(), &new_account, 10, initial_amount);
//
//     // execute transaction
//     let output = executor.execute_transaction(txn);
//     assert_eq!(
//         output.status(),
//         &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
//     );
//
//     // executor.add_account_data(&sender);
//     // let new_account = Account::new();
//     // let initial_amount = 1_000;
//     // let (txns_info, txns) = create_cyclic_transfers(&executor, &accounts, transfer_amount);
//     let txn = librablock_helper_tx(
//         &new_account, //sender: &Account,
//         &new_account, // receiver: &Account,
//         111, // seq_num: u64,
//         1000, //transfer_amount: u64,
//     );
//
//     // execute transaction
//     let mut execution_time = 0u128;
//     let now = Instant::now();
//     let output = executor.execute_and_apply(txn);
//     execution_time += now.elapsed().as_nanos();
//     println!("EXECUTION TIME: {}", execution_time);
//     // for txn_output in &output {
//     //     assert_eq!(
//     //         txn_output.status(),
//     //         &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
//     //     );
//     // }
//     // assert_eq!(accounts.len(), output.len());
//
//     // check_and_apply_transfer_output(&mut executor, &txns_info, &output);
//     // print_accounts(&executor, &accounts);
// }

#[test]
fn librablock () {
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();

    // let account = Account::new_genesis_account(libra_types::on_chain_config::config_address() );
    let genesis_account = Account::new_association();
    let validator_account = Account::new();
    let txn = librablock_helper_tx(&genesis_account, &validator_account, 1);
    executor.execute_and_apply(txn);

    // println!("address:{:?}", sender.address() );
    //
    // let initialization_output = executor.execute_and_apply(
    //     // TODO: Describe what is happening here. What are we initializing?
    //     redeem_initialize_txn(&sender.account(), sequence_number)
    // );
    // assert_eq!(
    //     initialization_output.status(),
    //     &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    // );
    //
    // // test data for the VDF proof
    // let challenge = b"test preimage";
    // let difficulty = 100;
    // // use a test pre image and a 100 difficulty
    // let proof = delay::do_delay(challenge, difficulty);
    //
    // //run the transaction script
    // let output = executor.execute_and_apply(
    //     // build the transaction script binary.
    //     redeem_txn(&sender.account(), sequence_number+1u64, challenge.to_vec(), difficulty, proof)
    // );
    //
    // assert_eq!(
    //     output.status(),
    //     &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    // );

}
