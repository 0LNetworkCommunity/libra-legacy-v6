//! genesis-wrapper

use crate::recover::GenesisRecovery;

use libra_types::{account_address::AccountAddress, transaction::{authenticator::AuthenticationKey}};

use std::path::PathBuf;
use vm_genesis::*;

/// Make recovery file in format needed
pub fn make_recovery_file(
    recover: Vec<GenesisRecovery>,
    _output_path: PathBuf,
) {
    // read file
    let mut vals: Vec<ValRecover> = vec![];

    for i in recover {
        let val_account: AccountAddress = i.account;
        let operator_delegated_account: AccountAddress = i.val_cfg.unwrap().delegated_account.unwrap();
        let val_auth_key: AuthenticationKey = i.auth_key.unwrap();

        vals.push(ValRecover {
            val_account,
            operator_delegated_account,
            val_auth_key,
        });
    }

    // get operators to recover
    // get vals to recover

    // Get a base gensis
    // let genesis = encode_recovery_genesis_transaction(recover, )?;

    // create transaction
    // save transaction
}
