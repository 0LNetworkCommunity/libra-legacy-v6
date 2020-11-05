use crate::account::Account;
use libra_types::{
    transaction::{SignedTransaction, TransactionArgument, Script},
};
use include_dir::{include_dir, Dir};
use compiled_stdlib::transaction_scripts::{StdlibScript, CompiledBytes};
use transaction_builder;

// For upgrade testing
pub fn demo_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let hello_world= 100u64;
    let script = transaction_builder::encode_demo_e2e_script(hello_world);
    sender
        .transaction()
        .script(script)
        .sequence_number(seq_num)
        .sign()
}