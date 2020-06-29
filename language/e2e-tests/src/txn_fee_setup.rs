use crate::{account::Account, gas_costs};

use libra_types::{
    account_config::{LBR_NAME},
    transaction::{SignedTransaction, TransactionArgument},
};
use stdlib::transaction_scripts::StdlibScript;
use move_core_types::{
    language_storage::TypeTag
};


pub fn txn_fee_tx_mint(
    sender: &Account,
    payee: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    let type_vec: Vec<TypeTag> = Vec::new();
    args.push(TransactionArgument::Address(payee.addr));

    sender.create_signed_txn_with_args(
        StdlibScript::TxFeeTestMint
            .compiled_bytes()
            .into_vec(),
        type_vec,
        args,
        seq_num,
        19_000_000,
        0,
        LBR_NAME.to_owned(),
    )
}

pub fn txn_fee_tx_move(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let args: Vec<TransactionArgument> = Vec::new();
    let type_vec: Vec<TypeTag> = Vec::new();

    sender.create_signed_txn_with_args(
        StdlibScript::TxFeeTestMove
            .compiled_bytes()
            .into_vec(),
        type_vec,
        args,
        seq_num,
        19_000_000,
        0,
        LBR_NAME.to_owned(),
    )
}

pub fn txn_fee_tx_distr(
    sender: &Account,
    seq_num: u64
) -> SignedTransaction {
    let args: Vec<TransactionArgument> = Vec::new();
    let type_vec: Vec<TypeTag> = Vec::new();

    sender.create_signed_txn_with_args(
        StdlibScript::TxFeeTestDistr
            .compiled_bytes()
            .into_vec(),
        type_vec,
        args,
        seq_num,
        19_000_000,
        0,
        LBR_NAME.to_owned(),
    )
}