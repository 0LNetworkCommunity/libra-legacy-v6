//! `epoch`

use crate::tx_params::TxParams;
use diem_client::BlockingClient as DiemClient;
use diem_types::{account_address::AccountAddress, account_state::AccountState};
use std::convert::TryFrom;

/// convenience to get the epoch
pub fn get_epoch(tx_params: &TxParams) -> u64 {
    let client = DiemClient::new(tx_params.url.clone());

    let (blob, _version) = client
        .get_account_state_blob(&AccountAddress::ZERO)
        .unwrap();
    if let Some(account_blob) = blob {
        let account_state = AccountState::try_from(&account_blob).unwrap();
        return account_state
            .get_configuration_resource()
            .unwrap()
            .unwrap()
            .epoch();
    }
    0
}
