//! genesis-wrapper

use crate::recover::{GenesisRecovery, RecoveryFile};

use libra_types::{account_address::AccountAddress, transaction::{authenticator::AuthenticationKey}};

use std::path::PathBuf;
use vm_genesis::*;

/// Make recovery file in format needed
pub fn make_recovery_file(
    recover: Vec<GenesisRecovery>,
    _output_path: PathBuf,
) {
    // read file
    let mut file = RecoveryFile::default();

    for i in recover {
        let val_account: AccountAddress = i.account;
        // get deduplicated validators info 
        match i.role {
            crate::recover::AccountRole::System => todo!(),
            crate::recover::AccountRole::Validator => {
              
            },
            crate::recover::AccountRole::Operator => todo!(),
            crate::recover::AccountRole::EndUser => todo!(),
        }
        // get deduplicated operator info
        let operator_delegated_account: AccountAddress = i.val_cfg.unwrap().delegated_account.unwrap();
        let val_auth_key: AuthenticationKey = i.auth_key.unwrap();
        
        // prevent duplicate fields
        if file.vals
        .iter()
        .find(|&a|{ a.val_account == val_account})
        .is_none() {
            file.vals.push(ValRecover {
              val_account,
              operator_delegated_account,
              val_auth_key,
          });
        }
        // file.vals.sort_by(|a, b| b.val_account.cmp(&a.val_account));

    }

    // get operators to recover
    // get vals to recover

    // Get a base gensis
    // let genesis = encode_recovery_genesis_transaction(recover, )?;

    // create transaction
    // save transaction
}
