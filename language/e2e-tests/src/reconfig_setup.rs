use crate::{account::Account, gas_costs};

use libra_types::{
    account_config::{LBR_NAME},
    transaction::{SignedTransaction, TransactionArgument},
};
use stdlib::transaction_scripts::StdlibScript;
use move_core_types::{
    language_storage::TypeTag,
};


pub fn bulk_update_setup(
    sender: &Account,
    accounts: &Vec<Account>,
    seq_num: u64
) -> SignedTransaction {
    // Create vectors to hold the arguments and typetags
    let mut args: Vec<TransactionArgument> = Vec::new();
    let type_vec: Vec<TypeTag> = Vec::new();

    // Populate args vector from fcn inputs
    for i in 0..5 {
        args.insert(i, TransactionArgument::Address(accounts.get(i).unwrap().addr));
    }

    // Create and output the signed txn script
    sender.create_signed_txn_with_args(
        StdlibScript::ReconfigSetup
            .compiled_bytes()
            .into_vec(),
        type_vec,
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 6,
        0,
        LBR_NAME.to_owned(),
    )
}


pub fn bulk_update(
    sender: &Account,
    accounts: &Vec<Account>,
    seq_num: u64
) -> SignedTransaction {
    // Create vectors to hold the arguments and typetags
    let mut args: Vec<TransactionArgument> = Vec::new();
    let type_vec: Vec<TypeTag> = Vec::new();

    // Populate args vector from fcn inputs
    for i in 0..5 {
        args.insert(i, TransactionArgument::Address(accounts.get(i).unwrap().addr));
    }

    // Create and output the signed txn script
    sender.create_signed_txn_with_args(
        StdlibScript::ReconfigBulkUpdate
            .compiled_bytes()
            .into_vec(),
        type_vec,
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 6,
        0,
        LBR_NAME.to_owned(),
    )
}
