use crate::account::Account;
use diem_framework_releases::legacy::transaction_scripts::CompiledBytes;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::transaction::{SignedTransaction, Script};
use include_dir::{include_dir, Dir};

// NOTE: rerun fixtures with: cargo run -p stdlib --release -- --create-upgrade-payload
const UPGRADE_DIR: Dir =
    include_dir!("../../../ol/fixtures/upgrade_payload/tx_scripts");

pub fn oracle_helper_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let stdlib_bytes = std::include_bytes!(
        "../../../../ol/fixtures/upgrade_payload/foo_stdlib.mv"
    );
    sender
        .transaction()
        .payload(
            transaction_builder::encode_ol_oracle_tx_script_function(
                1, stdlib_bytes.to_vec()
            )
        )
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
        .get_file("071_OracleUpgradeFooTx.mv")
        .unwrap_or_else(|| panic!("File 071_OracleUpgradeFooTx.mv does not exist"));

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