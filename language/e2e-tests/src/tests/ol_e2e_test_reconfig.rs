// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier},
    common_transactions::{create_validator_account_txn, register_validator_txn},
    executor::FakeExecutor,
    reconfig_setup::{bulk_update},
};
use libra_types::account_config::lbr_type_tag;
use transaction_builder::*;
// new_epoch


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
fn reconfig_bulk_update_test () { // Run with: `cargo xtest -p language-e2e-tests txn_fee_test -- --nocapture`
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();
    let sequence_number = 1u64;

    // Create some account types to be able to call a tx script and be validators
    let association_account = Account::new_association();
    let alice = Account::new();
    let bob = Account::new();
    let carol = Account::new();
    let sha = Account::new();
    let ram = Account::new();

    // // Add the account datas
    let assoc_acc_data = AccountData::with_account(
        association_account, 1_000_000,
        lbr_currency_code(),sequence_number, AccountTypeSpecifier::Empty);
    executor.add_account_data(&assoc_acc_data);

    // register the accounts as validators
    let mut txn = create_validator_account_txn(&assoc_acc_data.account(), &alice, 1);
    executor.execute_and_apply(txn);
    txn = create_validator_account_txn(&assoc_acc_data.account(), &bob, 2);
    executor.execute_and_apply(txn);
    txn = create_validator_account_txn(&assoc_acc_data.account(), &carol, 3);
    executor.execute_and_apply(txn);
    txn = create_validator_account_txn(&assoc_acc_data.account(), &sha, 4);
    executor.execute_and_apply(txn);
    txn = create_validator_account_txn(&assoc_acc_data.account(), &ram, 5);
    executor.execute_and_apply(txn);

    // give the validators some money
    let mint_amount = 10_000_000;
    executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
        encode_mint_script(lbr_type_tag(), &alice.address(), vec![], mint_amount),
        6,
    ));
    executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
        encode_mint_script(lbr_type_tag(), &bob.address(), vec![], mint_amount),
        7,
    ));
    executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
        encode_mint_script(lbr_type_tag(), &carol.address(), vec![], mint_amount),
        8,
    ));
    executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
        encode_mint_script(lbr_type_tag(), &sha.address(), vec![], mint_amount),
        9,
    ));

    // NOTE: Why is this different?
    executor.execute_and_apply(assoc_acc_data.account().signed_script_txn(
        encode_mint_gas_to_address_script(&ram.address(), vec![], mint_amount),
        10,
    ));
    executor.new_block();

    txn = register_validator_txn(&alice, vec![255; 32], vec![254; 32], vec![],
        vec![253; 32], vec![], 0);
    executor.execute_and_apply(txn);

    executor.new_block();

    txn = register_validator_txn(&bob, vec![255; 32], vec![254; 32], vec![],
        vec![253; 32], vec![], 0);
    executor.execute_and_apply(txn);

    executor.new_block();

    txn = register_validator_txn(&carol, vec![255; 32], vec![254; 32], vec![],
        vec![253; 32], vec![], 0);
    executor.execute_and_apply(txn);
    executor.new_block();
    txn = register_validator_txn(&sha, vec![255; 32], vec![254; 32], vec![],
        vec![253; 32], vec![], 0);
    executor.execute_and_apply(txn);
    executor.new_block();
    txn = register_validator_txn(&ram, vec![255; 32], vec![254; 32], vec![],
        vec![253; 32], vec![], 0);
    executor.execute_and_apply(txn);
    executor.new_block();

    // construct a valid and signed tx script.

    let bulk_update = bulk_update(&assoc_acc_data.account(), &alice,
                    &bob, &carol, &sha,
                    &ram, 11);

    print!("bulk_update\n{:?}", bulk_update);
    // let distr = txn_fee_tx_distr(&assoc_acc_data.account(), 2);

    executor.new_block();
    let tx_out = executor.execute_and_apply(bulk_update);

    // println!("gas used: {:?}, running second", tx_out.gas_used());
    // executor.new_block();
    // tx_out = executor.execute_and_apply(calc);

    // println!("gas used: {:?}, running third", tx_out.gas_used());
    // executor.new_block();
    // tx_out = executor.execute_and_apply(distr);
    println!("gas used: {:?}", tx_out.gas_used());

    // let account_state = executor
    //     .read_account_resource(&association_account)
    //     .expect("sender must exist");
    // // TODO: get a list of validators here. Test that the stats is inserting the validator votes.
    //
    // println!("history_state \n{:?}", &account_state.received_events());
}
