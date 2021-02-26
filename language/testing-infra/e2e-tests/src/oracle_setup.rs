use crate::account::Account;
use diem_types::{
    transaction::{SignedTransaction, TransactionArgument, Script},
};
use include_dir::{include_dir, Dir};
use compiled_stdlib::transaction_scripts::{StdlibScript, CompiledBytes};

// NOTE: rerun fixtures with: cargo run -p stdlib --release -- --create-upgrade-payload
const UPGRADE_DIR: Dir =
    include_dir!("../../../fixtures/upgrade_payload/tx_scripts");

pub fn oracle_helper_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();
    args.push(TransactionArgument::U64(1));
    let stdlib_bytes = std::include_bytes!("../../../../fixtures/upgrade_payload/foo_stdlib.mv"); 
    let stdlib_vec = stdlib_bytes.to_vec();
    args.push(TransactionArgument::U8Vector(stdlib_vec));

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