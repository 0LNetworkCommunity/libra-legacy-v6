//! `relay`

#![forbid(unsafe_code)]
use crate::{submit_tx::{TxParams, wait_for_tx}};
use anyhow::Error;
use cli::{libra_client::LibraClient};
use libra_json_rpc_types::views::{TransactionView};
use libra_types::{account_address::AccountAddress, transaction::SignedTransaction};

/// submit a previously signed tx, perhaps to be submitted by a different account than the signer account.
pub fn relay_tx(
    tx_params: &TxParams,
    txn: SignedTransaction,
    original_signer: AccountAddress,
) -> Result<TransactionView, Error> {
    let mut client = LibraClient::new(
        tx_params.url.clone(), tx_params.waypoint
    ).unwrap();

    // let chain_id = ChainId::new(client.get_metadata().unwrap().chain_id);
    let (account_state,_) = client.get_account(
        original_signer, true
    ).unwrap();

    let original_signer_sequence_number = match account_state {
        Some(av) => av.sequence_number,
        None => 0,
    };
    // Submit the transaction with libra_client
    match client.submit_transaction(
        None,
        txn,
      ){
        Ok(_) => {
            match wait_for_tx(
                original_signer, original_signer_sequence_number, &mut client
            ) {
                Some(res) => Ok(res),
                None => Err(Error::msg("No Transaction View returned"))
            }
        }
        Err(err) => Err(err)
    }
}