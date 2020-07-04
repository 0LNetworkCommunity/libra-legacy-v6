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
    accounts: &Vec<Account>,
    seq_num: u64
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    let type_vec: Vec<TypeTag> = Vec::new();
    for i in 0..5 {
        args.insert(i, TransactionArgument::Address(accounts.get(i).unwrap().addr));
    }

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
