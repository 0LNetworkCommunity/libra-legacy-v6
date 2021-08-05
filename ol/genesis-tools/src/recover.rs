//! recovery

use anyhow::{Error, bail};
use libra_types::{account_state::AccountState, validator_config::ValidatorConfigResource, write_set::WriteSetMut};
use move_core_types::move_resource::MoveResource;


fn get_recovery_structs(account_state: &AccountState) -> Result<ValidatorConfigResource, Error> {
        let mut ws = WriteSetMut::new(vec![]);
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