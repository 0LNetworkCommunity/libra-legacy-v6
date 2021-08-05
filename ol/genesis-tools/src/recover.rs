//! recovery

use anyhow::{Error, bail};
use libra_types::{account_state::AccountState, validator_config::ValidatorConfigResource, write_set::WriteSetMut};
use move_core_types::move_resource::MoveResource;
use ol_types::miner_state::MinerStateResource;

enum AccountRole {
  System,
  Validator,
  Operator,
  EndUser
}

enum WalletType {
  None,
  Slow,
  Community,
}
struct GenesisRecovery {
  val_cfg: ValidatorConfigResource,
  balance: u64,
  miner_state: MinerStateResource,
  role: AccountRole,
  wallet_type: WalletType,
  // TODO: Fullnode State? // rust struct does not exist
  // TODO: Autopay? // rust struct does not exist
}
/// create a recovery struct from an account state.
pub fn get_recovery_struct(account_state: &AccountState) -> Result<GenesisRecovery, Error> {
        let _ws = WriteSetMut::new(vec![]);
        if let Some(address) = account_state.get_account_address()? {
            // iterate over all the account's resources\
            for (k, v) in account_state.iter() {
              // extract the validator config resource
              if k.clone() == ValidatorConfigResource::resource_path() {
                let val_config: ValidatorConfigResource = lcs::from_bytes(v)?;
                return Ok(val_config)
              }
              // // get any operator configs that may exist
              // if k.clone() == ValidatorOperatorConfigResource::resource_path() {
              //   let val_config: ValidatorOperatorConfigResource = lcs::from_bytes(v);

              // }                

            }
            println!("processed account: {:?}", address);

            
        }

        bail!("ERROR: No address for AccountState: {:?}", account_state);
}