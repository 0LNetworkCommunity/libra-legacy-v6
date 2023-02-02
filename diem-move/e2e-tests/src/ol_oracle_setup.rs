use crate::account::Account;
use diem_transaction_builder::stdlib as transaction_builder;
use move_core_types::{ident_str, language_storage::ModuleId};
use diem_types::{
    account_address::AccountAddress,
    transaction::{ScriptFunction, SignedTransaction, TransactionPayload},
};

pub fn oracle_helper_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let stdlib_bytes = std::include_bytes!(
        "../../../ol/fixtures/upgrade_payload/foo_stdlib.mv"
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

// Generated temporarily and copied from `sdk/transaction-builder/src/stdlib.rs`
// See https://github.com/0LNetworkCommunity/libra/wiki/Stdlib-Upgrade-payload-(v5)
pub fn encode_ol_oracle_upgrade_foo_tx_script_function() -> TransactionPayload {
    TransactionPayload::ScriptFunction(ScriptFunction::new(
        ModuleId::new(
            AccountAddress::new([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]),
            ident_str!("OracleUpgradeFooTx").to_owned(),
        ),
        ident_str!("ol_oracle_upgrade_foo_tx").to_owned(),
        vec![],
        vec![],
    ))
}

// For upgrade testing
pub fn upgrade_foo_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let payload = encode_ol_oracle_upgrade_foo_tx_script_function();
    sender
        .transaction()
        .payload(payload)
        .sequence_number(seq_num)
        .sign()
}