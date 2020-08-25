use crate::account::Account;
use libra_types::transaction::{SignedTransaction, TransactionArgument};
use stdlib::transaction_scripts::StdlibScript;
use crate::gas_costs;
use libra_types::account_config::LBR_NAME;
use move_core_types::account_address::AccountAddress;

/// This is test infrastructure. Helps build a signed transaction script of the Redeem module.
pub fn redeem_txn(
    sender: &Account,
    seq_num: u64,
    challenge: Vec<u8>,
    difficulty: u64,
    solution: Vec<u8>,
    tower_height: u64 ) -> SignedTransaction {
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

pub fn redeem_txn_onboarding(sender: &Account, seq_num: u64, challenge: Vec<u8>, difficulty: u64, solution: Vec<u8>, expected_address: AccountAddress) -> SignedTransaction {
    let args = vec![
        TransactionArgument::U8Vector(challenge),
        TransactionArgument::U64(difficulty),
        TransactionArgument::U8Vector(solution),
        TransactionArgument::Address(expected_address),
    ];
    sender.create_signed_txn_with_args(
        StdlibScript::RedeemOnboarding
            .compiled_bytes()
            .into_vec(),
        vec![],
        args,
        seq_num,
        gas_costs::TXN_RESERVED * 4,
        0,
        LBR_NAME.to_owned(),
    )
}