// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{self, Account, AccountData},
    // common_transactions::peer_to_peer_txn,
    executor::FakeExecutor,
    librablock_setup::librablock_helper_tx,
};


use libra_crypto::HashValue;
use libra_state_view::StateView;
use libra_types::{
    access_path::AccessPath,
    account_config::{AccountResource, BalanceResource},
    block_metadata::{new_block_event_key, BlockMetadata, NewBlockEvent},
    on_chain_config::{OnChainConfig, VMPublishingOption, ValidatorSet},
    transaction::{
        SignedTransaction, Transaction, TransactionOutput, TransactionStatus, VMValidatorResult,
    },
    vm_error::{StatusCode, VMStatus},
    write_set::WriteSet,
};

#[test]
fn librablock () { // Run with: `cargo xtest -p language-e2e-tests librablock -- --nocapture`
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();

    // meed to create some account types to be able to call a tx script.
    let genesis_account = Account::new_association();
    let validator_account = Account::new();

    // construct a valid and signed tx script.
    let txn = librablock_helper_tx(&genesis_account, &validator_account, 1);

    // TODO: force the test runner to create a new block before running the test.
    // Unclear how this works. At times it seems the executor will start fresh on the next instruction.
    executor.new_block(); // block parameters include the validators which voted on the previous block.
    // execute and persist the transaction
    executor.execute_and_apply(txn);
    // executor.execute_block(vec!(txn));
}

// #[test]
// fn librablock_newblock_tx () {
//     // TODO: test we are getting the voter vector from the BlockMetadata
//     let mut executor = FakeExecutor::from_genesis_file();
//     let result = executor.new_block();
//     println!("executor.new_block(); \n{:?}", result );
//     return result
// }


// fn newblock_tx () -> Transaction {
    // TODO Add the block metadata here.
    // let validator_set = ValidatorSet::fetch_config(&self.data_store)
    //     .expect("Unable to retrieve the validator set from storage");
    // self.block_time += 1;
    //
    // // OL: Mocking the validator signatures in previous block.
    // let mut vec_validator_adresses = vec![];
    // for i in validator_set.payload().iter() {
    //     //println!("\nvalidator: \n{:?}",i );
    //     vec_validator_adresses.push(*i.account_address())
    // }

    // let new_block = BlockMetadata::new(
    //     HashValue::zero(),
    //     111, // OL: block height/round TODO: This does not appear in tests.
    //     20000,
    //     vec![], // OL: Mocking the validator signatures in previous block.
    //     Account::new().addr,
    // );
    //
    // Transaction::BlockMetadata(new_block)

    // let output = self
    //     .execute_transaction_block(vec![Transaction::BlockMetadata(new_block)])
    // tx_vec.push(Transaction::BlockMetadata(new_block));
//}
