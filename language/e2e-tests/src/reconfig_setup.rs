use crate::{account::Account, gas_costs};

use libra_types::{
    account_config::{LBR_NAME},
    transaction::{SignedTransaction, TransactionArgument},
};
use stdlib::transaction_scripts::StdlibScript;
use move_core_types::{
    language_storage::TypeTag, 
};


pub fn bulk_update(
    sender: &Account,
    alice: &Account,
    bob: &Account,
    carol: &Account,
    sha: &Account,
    ram: &Account,
    seq_num: u64
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    let type_vec: Vec<TypeTag> = Vec::new();
    args.push(TransactionArgument::Address(alice.addr));
    args.push(TransactionArgument::Address(bob.addr));
    args.push(TransactionArgument::Address(carol.addr));
    args.push(TransactionArgument::Address(sha.addr));
    args.push(TransactionArgument::Address(ram.addr));

    sender.create_signed_txn_with_args(
        StdlibScript::ReconfigBulkUpdate
            .compiled_bytes()
            .into_vec(),
        type_vec,
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 3,
        0,
        LBR_NAME.to_owned(),
    )
}