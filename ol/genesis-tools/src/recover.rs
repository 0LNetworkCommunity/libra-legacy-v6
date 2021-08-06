//! recovery

use std::{convert::TryFrom, fs, io::Write, path::PathBuf};

use anyhow::{bail, Error};
use libra_types::{
    account_config::BalanceResource, account_state::AccountState,
    account_state_blob::AccountStateBlob, validator_config::ValidatorConfigResource,
};
use move_core_types::move_resource::MoveResource;
use ol_types::miner_state::MinerStateResource;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
enum AccountRole {
    System,
    Validator,
    Operator,
    EndUser,
}
#[derive(Debug, Serialize, Deserialize)]
enum WalletType {
    None,
    Slow,
    Community,
}

/// The basic structs needed to recover account state in a new network.
#[derive(Debug, Serialize, Deserialize)]
pub struct GenesisRecovery {
    role: AccountRole,
    balance: Option<BalanceResource>,
    val_cfg: Option<ValidatorConfigResource>,
    miner_state: Option<MinerStateResource>,
    // wallet_type: Option<WalletType>,
    // TODO: Fullnode State? // rust struct does not exist
    // TODO: Autopay? // rust struct does not exist
}

/// make the writeset for the genesis case. Starts with an unmodified account state and make into a writeset.
pub fn accounts_into_recovery(
    account_state_blobs: &Vec<AccountStateBlob>,
) -> Result<Vec<GenesisRecovery>, Error> {
    let mut to_recover = vec![];
    for blob in account_state_blobs {
        let account_state = AccountState::try_from(blob)?;
        match parse_recovery(&account_state) {
            Ok(gr) => to_recover.push(gr),
            Err(e) => println!(
                "WARN: could not recover account, continuing. Message: {:?}",
                e
            ),
        }
    }
    println!("Total accounts read: {}", &account_state_blobs.len());

    Ok(to_recover)
}

/// create a recovery struct from an account state.
pub fn parse_recovery(account_state: &AccountState) -> Result<GenesisRecovery, Error> {
    let mut gr = GenesisRecovery {
        role: AccountRole::EndUser,
        balance: None,
        val_cfg: None,
        miner_state: None,
    };

    if let Some(address) = account_state.get_account_address()? {
        // iterate over all the account's resources\
        for (k, v) in account_state.iter() {
            // extract the validator config resource
            if k.clone() == BalanceResource::resource_path() {
                gr.balance = lcs::from_bytes(v).ok();
            }
            if k.clone() == ValidatorConfigResource::resource_path() {
                gr.val_cfg = lcs::from_bytes(v).ok();
            }
            if k.clone() == MinerStateResource::resource_path() {
                gr.miner_state = lcs::from_bytes(v).ok();
            }
        }
        println!("processed account: {:?}", address);
    }

    bail!("ERROR: No address for AccountState: {:?}", account_state);
}

/// Save genesis recovery file
pub fn save_recovery_file(data: &Vec<GenesisRecovery>, path: &PathBuf) -> Result<(), Error> {
    let j = serde_json::to_string(data)?;
    let mut file = fs::File::create(path).expect("Could not genesis_recovery create file");
    file.write_all(j.as_bytes())
        .expect("Could not write account recovery");
    Ok(())
}

