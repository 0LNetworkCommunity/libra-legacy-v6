use crate::{account::Account, gas_costs};

use compiler::Compiler;
use libra_types::{
    account_address::AccountAddress,
    account_config,
    account_config::{lbr_type_tag, LBR_NAME},
    transaction::{RawTransaction, SignedTransaction, TransactionArgument},
};
use once_cell::sync::Lazy;
use stdlib::transaction_scripts::StdlibScript;


pub fn librablock_helper_tx(
    sender: &Account,
    new_account: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();

    sender.create_signed_txn_with_args(
        StdlibScript::LibraBlockTestHelper
            .compiled_bytes()
            .into_vec(),
        vec![lbr_type_tag()], // TODO: what is this parameter, and why do we need to pass an lbr type? Fails if removed.
        args, //TODO: Why does args not match the previous param ty_args in length?
        seq_num,
        gas_costs::TXN_RESERVED * 3,
        0,
        LBR_NAME.to_owned(),
    )
}
