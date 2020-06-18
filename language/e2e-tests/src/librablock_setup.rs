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



pub fn librablock_helper_tx_old(
    sender: &Account,
    receiver: &Account,
    seq_num: u64,
    transfer_amount: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::Address(*receiver.address()));
    args.push(TransactionArgument::U64(transfer_amount));
    args.push(TransactionArgument::U8Vector(vec![]));
    args.push(TransactionArgument::U8Vector(vec![]));

    // get a SignedTransaction
    sender.create_signed_txn_with_args(
        StdlibScript::PeerToPeerWithMetadata
            .compiled_bytes()
            .into_vec(),
        vec![lbr_type_tag()],
        args,
        seq_num,
        gas_costs::TXN_RESERVED, // this is a default for gas
        0,                       // this is a default for gas
        LBR_NAME.to_owned(),
    )
}

pub fn librablock_helper_tx(
    sender: &Account,
    new_account: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    //args.push(TransactionArgument::Address(*new_account.address()));
    // args.push(TransactionArgument::U8Vector(new_account.auth_key_prefix()));

    sender.create_signed_txn_with_args(
        StdlibScript::LibraBlockTestHelper
            .compiled_bytes()
            .into_vec(),
        vec![lbr_type_tag()],
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 3,
        0,
        LBR_NAME.to_owned(),
    )
}
