use crate::{account::Account, gas_costs};
use libra_types::{
    account_config::{lbr_type_tag, LBR_NAME},
    transaction::SignedTransaction,
};
use stdlib::transaction_scripts::StdlibScript;

// Function definition of rust function to create signed tansaction object from
// the transaction script LibraBlockTestHelper
pub fn librablock_helper_tx(
    sender: &Account,
    seq_num: u64,
) -> SignedTransaction {
    sender.create_signed_txn_with_args(
        StdlibScript::LibraBlockTestHelper
            .compiled_bytes()
            .into_vec(),
        vec![lbr_type_tag()],
        vec![],
        seq_num,
        gas_costs::TXN_RESERVED,
        0,
        LBR_NAME.to_owned(),
    )
}
