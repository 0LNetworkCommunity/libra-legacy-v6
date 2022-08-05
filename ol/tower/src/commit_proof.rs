//! MinerApp submit_tx module
#![forbid(unsafe_code)]
use cli::{diem_client::DiemClient, AccountData, AccountStatus};
use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use ol_types::block::VDFProof;
use txs::{
    sign_tx::sign_tx,
    submit_tx::{eval_tx_status, submit_tx, TxError},
    tx_params::TxParams,
};

/// Submit a miner transaction to the network.
pub fn commit_proof_tx(tx_params: &TxParams, block: VDFProof) -> Result<TransactionView, TxError> {
    // Create a client object
    let client = DiemClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let chain_id = tx_params.chain_id;

    // For sequence number
    let account_state = client.get_account(&tx_params.signer_address)?;
    let sequence_number = match account_state {
        Some(av) => av.sequence_number,
        None => 0,
    };

    let script = if tx_params.is_operator {
        transaction_builder::encode_minerstate_commit_by_operator_script_function(
            tx_params.owner_address.clone(),
            block.preimage.clone(),
            block.proof.clone(),
            block.difficulty(),
            block.security(),
        )
    } else {
        // if owner sending with mnemonic
        transaction_builder::encode_minerstate_commit_script_function(
            block.preimage.clone(),
            block.proof.clone(),
            block.difficulty(),
            block.security(),
        )
    };

    let signed_tx = sign_tx(script, tx_params, sequence_number, chain_id)?;

    // get account_data struct
    let mut signer_account_data = AccountData {
        address: tx_params.signer_address,
        authentication_key: Some(tx_params.auth_key.to_vec()),
        key_pair: Some(tx_params.keypair.clone()),
        sequence_number,
        status: AccountStatus::Persisted,
    };

    let t = submit_tx(client, signed_tx, &mut signer_account_data)?;
    eval_tx_status(t)
}
