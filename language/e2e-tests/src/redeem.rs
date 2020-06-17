use crate::account::Account;
use libra_types::transaction::{SignedTransaction, TransactionArgument};
use stdlib::transaction_scripts::StdlibScript;
use crate::gas_costs;
use libra_types::account_config::LBR_NAME;

/// Returns a transaction to change the keys for the given account.
pub fn redeem_txn(sender: &Account, seq_num: u64, challenge: Vec<u8>, difficulty: u64, solution: Vec<u8> ) -> SignedTransaction {
    let args = vec![
        TransactionArgument::U8Vector(challenge),
        TransactionArgument::U64(difficulty),
        TransactionArgument::U8Vector(solution),
    ];
    sender.create_signed_txn_with_args(
        StdlibScript::Redeem
            .compiled_bytes()
            .into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED,
        0,
        LBR_NAME.to_owned(),
    )
}

/// Returns a transaction to change the keys for the given account.
pub fn redeem_initialize_txn(sender: &Account, seq_num: u64 ) -> SignedTransaction {
    let args = vec![];

    sender.create_signed_txn_with_args(
        StdlibScript::RedeemInitialize
            .compiled_bytes()
            .into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED,
        0,
        LBR_NAME.to_owned(),
    )
}
