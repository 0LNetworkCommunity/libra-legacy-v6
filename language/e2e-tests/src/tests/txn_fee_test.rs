// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier},
    // common_transactions::peer_to_peer_txn,
    executor::FakeExecutor,
    txn_fee_setup::{txn_fee_tx_mint, txn_fee_tx_move, txn_fee_tx_distr}
};


// use libra_types::{
//     account_config::{AccountResource, BalanceResource},
//     block_metadata::{new_block_event_key, BlockMetadata, NewBlockEvent},
//     on_chain_config::{OnChainConfig, VMPublishingOption, ValidatorSet},
//     transaction::{
//         SignedTransaction, Transaction, TransactionOutput, TransactionStatus, VMValidatorResult,
//     },
//     vm_error::{StatusCode, VMStatus},
//     write_set::WriteSet,
// };

#[test]
fn txn_fees_test () { // Run with: `cargo xtest -p language-e2e-tests txn_fee_test -- --nocapture`
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();
    let sequence_number = 1u64;

    // meed to create some account types to be able to call a tx script.
    let association_account = Account::new_association();
    let account = Account::new();

    let assoc_acc_data = AccountData::with_account(
        association_account, 1_000_000,
        lbr_currency_code(),sequence_number, AccountTypeSpecifier::Empty);
    executor.add_account_data(&assoc_acc_data);

    let acc_data = AccountData::with_account(
        account, 5_000_000,
        lbr_currency_code(),sequence_number, AccountTypeSpecifier::Empty);
    executor.add_account_data(&acc_data);

    // construct a valid and signed tx script.
    let mint = txn_fee_tx_mint(&assoc_acc_data.account(), &acc_data.account(), 1);
    //let calc = txn_fee_tx_move(&assoc_acc_data.account(), 2);
    let distr = txn_fee_tx_distr(&assoc_acc_data.account(), 2);

    executor.new_block(); 
    let mut tx_out = executor.execute_and_apply(mint);

    // println!("gas used: {:?}, running second", tx_out.gas_used());
    // executor.new_block();
    // tx_out = executor.execute_and_apply(calc);

    // println!("gas used: {:?}, running third", tx_out.gas_used());
    executor.new_block();
    tx_out = executor.execute_and_apply(distr);
    println!("gas used: {:?}", tx_out.gas_used());

    // let account_state = executor
    //     .read_account_resource(&association_account)
    //     .expect("sender must exist");
    // // TODO: get a list of validators here. Test that the stats is inserting the validator votes.
    //
    // println!("history_state \n{:?}", &account_state.received_events());
}
