//! `epoch`

use std::convert::TryFrom;

use cli::diem_client::DiemClient;
use diem_types::{account_address::AccountAddress, account_state::AccountState};

use crate::tx_params::TxParams;
use std::process::exit;

/// convenience to get the epoch
pub fn get_epoch(tx_params: &TxParams) -> u64 {
    let client = match DiemClient::new(tx_params.url.clone(), tx_params.waypoint){
        Ok(r) => r,
        Err(e) => {
            println!("Error: {}",e.to_string());
            exit(1)
        },
    };

    let (blob, _version) = client
        .get_account_state_blob(&AccountAddress::ZERO)
        .unwrap();
    if let Some(account_blob) = blob {
        let account_state = match AccountState::try_from(&account_blob){
            Ok(r) => dbg!(r),
            Err(e) => {
                    println!("Error: {}",e.to_string());
                    exit(1)
                },
        };
        return account_state
            .get_configuration_resource()
            .unwrap()
            .unwrap()
            .epoch();
    }
    0
}
