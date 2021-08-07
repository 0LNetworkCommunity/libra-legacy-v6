//! recovery

use std::{convert::TryFrom, fs, io::Write, path::PathBuf};

use anyhow::{bail, Error};
use libra_types::{account_address::AccountAddress, account_config::BalanceResource, account_state::AccountState, account_state_blob::AccountStateBlob, on_chain_config::ConfigurationResource, transaction::authenticator::AuthenticationKey, validator_config::ValidatorConfigResource};
use move_core_types::move_resource::MoveResource;
use ol_types::{community_wallet::CommunityWalletsResource, miner_state::MinerStateResource};
use serde::{Deserialize, Serialize};
use vm_genesis::{OperRecover, UserRecover, ValRecover};

#[derive(Debug, Serialize, Deserialize)]
pub enum AccountRole {
    System,
    Validator,
    Operator,
    EndUser,
}
#[derive(Debug, Serialize, Deserialize)]
pub enum WalletType {
    None,
    Slow,
    Community,
}

/// The basic structs needed to recover account state in a new network.
/// This is necessary for catastrophic recoveries, when the source code changes too much. Like what is going to happen between v4 and v5, where the source code of v5 will not be able to work with objects from v4. We need an intermediary file.
#[derive(Debug, Serialize, Deserialize)]
pub struct GenesisRecovery {
    ///
    pub account: AccountAddress,
    ///
    pub auth_key: Option<AuthenticationKey>,
    ///
    pub role: AccountRole,
    ///
    pub balance: Option<BalanceResource>,
    ///
    pub val_cfg: Option<ValidatorConfigResource>,
    ///
    pub miner_state: Option<MinerStateResource>,
    // wallet_type: Option<WalletType>,
    // TODO: Fullnode State? // rust struct does not exist
    // TODO: Autopay? // rust struct does not exist
}

/// RecoveryFile
// #[derive(Debug, Serialize, Deserialize)]
pub struct RecoveryFile {
    ///
    pub vals: Vec<ValRecover>,
    ///
    pub opers: Vec<OperRecover>,
    ///
    pub users: Vec<UserRecover>,

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
pub fn parse_recovery(state: &AccountState) -> Result<GenesisRecovery, Error> {
    let mut gr = GenesisRecovery {
        account: AccountAddress::ZERO,
        auth_key: None,
        role: AccountRole::EndUser,
        balance: None,
        val_cfg: None,
        miner_state: None,
    };

    if let Some(address) = state.get_account_address()? {
        gr.account = address;
        // iterate over all the account's resources\
        for (k, v) in state.iter() {
            // extract the validator config resource
            if k == &BalanceResource::resource_path() {
                gr.balance = lcs::from_bytes(v).ok();
            } else if k == &ValidatorConfigResource::resource_path() {
                gr.val_cfg = lcs::from_bytes(v).ok();
            } else if k == &MinerStateResource::resource_path() {
                gr.miner_state = lcs::from_bytes(v).ok();
            }

            if address == AccountAddress::ZERO {
                // structs only on 0x0 address
                if k == &ConfigurationResource::resource_path() {
                    gr.miner_state = lcs::from_bytes(v).ok();
                } else if k == &CommunityWalletsResource::resource_path() {
                    gr.miner_state = lcs::from_bytes(v).ok();
                }
            }
        }
        println!("processed account: {:?}", address);
    }

    bail!("ERROR: No address for AccountState: {:?}", state);
}

/// Save genesis recovery file
pub fn save_recovery_file(data: &Vec<GenesisRecovery>, path: &PathBuf) -> Result<(), Error> {
    let j = serde_json::to_string(data)?;
    let mut file = fs::File::create(path).expect("Could not genesis_recovery create file");
    file.write_all(j.as_bytes())
        .expect("Could not write account recovery");
    Ok(())
}
