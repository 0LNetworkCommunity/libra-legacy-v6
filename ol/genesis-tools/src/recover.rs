//! recovery

use anyhow::{Error, bail};
use libra_types::{account_config::BalanceResource, account_state::AccountState, validator_config::ValidatorConfigResource};
use move_core_types::move_resource::MoveResource;
use ol_types::miner_state::MinerStateResource;
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
enum AccountRole {
  System,
  Validator,
  Operator,
  EndUser
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
/// create a recovery struct from an account state.
pub fn get_recovery_struct(account_state: &AccountState) -> Result<GenesisRecovery, Error> {
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