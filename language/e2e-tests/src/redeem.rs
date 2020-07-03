use crate::account::Account;
use libra_types::transaction::{SignedTransaction, TransactionArgument};
use stdlib::transaction_scripts::StdlibScript;
use crate::gas_costs;
use libra_types::account_config::LBR_NAME;

/// This is test infrastructure. Helps build a signed transaction script of the Redeem module.
pub fn redeem_txn(sender: &Account, seq_num: u64, challenge: Vec<u8>, difficulty: u64, solution: Vec<u8>, tower_height: u64 ) -> SignedTransaction {
    let args = vec![
        TransactionArgument::U8Vector(challenge),
        TransactionArgument::U64(difficulty),
        TransactionArgument::U8Vector(solution),
        TransactionArgument::U64(tower_height),

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

/// This is test infrastructure. Helps build a signed transaction script TO INITIALIZE THE REDEEM module
/// TODO: This may not be necessary if the Redeem module is initialized in the Genesis.move
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
