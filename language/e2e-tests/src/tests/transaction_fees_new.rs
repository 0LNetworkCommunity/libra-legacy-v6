// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account::{Account, AccountData},
    executor::FakeExecutor,
    gas_costs,
    librablock_setup::librablock_helper_tx,
    txfee_setup::txfee_helper_tx

};
use libra_crypto::{ed25519::Ed25519PrivateKey, PrivateKey, Uniform};
use libra_types::{
    account_config::{self, BurnEvent, LBR_NAME},
    transaction::{authenticator::AuthenticationKey, TransactionArgument},
    vm_error::StatusCode,
};
use move_core_types::{
    identifier::Identifier,
    language_storage::{StructTag, TypeTag},
};
use std::convert::TryFrom;
use stdlib::transaction_scripts::StdlibScript;
use transaction_builder::{encode_mint_lbr_to_address_script};


#[test]
fn txn_fees_new_calc_one_tx_fees() {
    let mut executor = FakeExecutor::from_genesis_file();
    // this creates a new block with validator info.
    executor.new_block();

    let association_account = Account::new_association();
    let validator_account = Account::new();

    // Let's do a simple no-op operation to create a state transition
    // librablock_helper_tx this with print some helpful debugs. Look for places with a 7e57 to lookup your print (hex for "TEST")
    let txn = librablock_helper_tx(&association_account, 1);
    executor.execute_and_apply(txn);

    // measure the gas used.
    // create a new account.
    let sender = AccountData::new(0, 0);
    executor.add_account_data(&sender);


    let gas_used = {
        let privkey = Ed25519PrivateKey::generate_for_testing();
        let pubkey = privkey.public_key();
        let new_key_hash = AuthenticationKey::ed25519(&pubkey).to_vec();
        let args = vec![TransactionArgument::U8Vector(new_key_hash)];
        let status = executor.execute_and_apply(
            sender.account().create_signed_txn_with_args(
                StdlibScript::RotateAuthenticationKey
                    .compiled_bytes()
                    .into_vec(),
                vec![],
                args,
                0,
                gas_costs::TXN_RESERVED,
                1,
                LBR_NAME.to_owned(),
            ),
        );
        assert_eq!(
            status.status().vm_status().major_status,
            StatusCode::EXECUTED
        );
        status.gas_used()
    };
}

#[test]
fn txn_fees_new_check_distribute_gas() {
    let mut executor = FakeExecutor::from_genesis_file();
    // this creates a new block with validator info.
    executor.new_block();

    let association_account = Account::new_association();

    // Let's do a simple no-op operation to create a state transition
    // librablock_helper_tx this with print some helpful debugs. Look for places with a 7e57 to lookup your print (hex for "TEST")
    let txn = librablock_helper_tx(&association_account, 1);
    executor.execute_and_apply(txn);

    // measure the gas used.
    // create a new account.
    let sender = AccountData::new(0, 0);
    executor.add_account_data(&sender);

    // PERHAPS FIND A WAY TO DEPOSIT FUNDS DIRECTLY INTO 0xFEE
    let setup_fees_txn = librablock_helper_tx(&association_account, 2); // make sure you have the right "sequence number" in this tx
    executor.execute_and_apply(setup_fees_txn);

}
