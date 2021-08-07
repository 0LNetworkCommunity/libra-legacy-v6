//! genesis-wrapper

use crate::recover::GenesisRecovery;
use anyhow::Error;
use libra_types::{account_address::AccountAddress, chain_id::ChainId, on_chain_config::VMPublishingOption, transaction::{ChangeSet, Transaction, WriteSetPayload, authenticator::AuthenticationKey}};
use libra_vm::{data_cache::StateViewCache, txn_effects_to_writeset_and_events};
use serde_json::Value;
use std::path::PathBuf;
use vm_genesis::*;

pub fn make_recovery_file(
    recover: Vec<GenesisRecovery>,
    output_path: PathBuf,
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
