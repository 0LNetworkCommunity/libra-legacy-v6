use crate::account::Account;
use libra_types::{
    transaction::{SignedTransaction, TransactionArgument, Script},
};
use include_dir::{include_dir, Dir};
use compiled_stdlib::transaction_scripts::{StdlibScript, CompiledBytes};
// TODO: should delete if we are not hashing the payload
// use std::collections::hash_map::DefaultHasher;
// use std::hash::{Hash, Hasher};

const UPGRADE_DIR: Dir =
    include_dir!("../../../language/stdlib/upgrade_payload");

pub fn oracle_helper_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U64(1));
    let stdlib_bytes = std::include_bytes!("../../../stdlib/upgrade_payload/stdlib.mv"); 
    let stdlib_vec = stdlib_bytes.to_vec();
    // let mut hasher = DefaultHasher::new();
    // Hash::hash_slice(&stdlib_vec, &mut hasher);
    // let hashed = hasher.finish();
    // println!("Hash is {:x}!", *&hashed);
    args.push(TransactionArgument::U8Vector(stdlib_vec));

    // sender.create_signed_txn_with_args(
    //     StdlibScript::OracleTx
    //         .compiled_bytes()
    //         .into_vec(),
    //     vec![],
    //     args,
    //     seq_num,
    //     1_000_000_000, // give sufficient gas
    //     0,
    //     LBR_NAME.to_owned(),
    // )
    sender
        .transaction()
        .script(Script::new(
            StdlibScript::OracleTx
                .compiled_bytes()
                .into_vec(),
            vec![],
            args,
        ))
        .sequence_number(seq_num)
        .max_gas_amount(1_000_000_000) // give sufficient gas
        .sign()
}

// For upgrade testing
pub fn upgrade_foo_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let file = UPGRADE_DIR
                .get_file("ol_oracle_upgrade_foo_tx.mv")
                .unwrap_or_else(|| panic!("File ol_oracle_upgrade_foo_tx.mv does not exist"));

    let compiled_code = CompiledBytes::new(file.contents().to_vec()).into_vec();
    // sender.create_signed_txn_with_args(
    //     compiled_code,
    //     vec![],
    //     vec![],
    //     seq_num,
    //     gas_costs::TXN_RESERVED, 
    //     0,
    //     LBR_NAME.to_owned(),
    // )

    sender
        .transaction()
        .script(Script::new(
            compiled_code,
            vec![],
            vec![],
        ))
        .sequence_number(seq_num)
        .sign()
}