//! genesis-wrapper

use crate::recover::AccountRole::*;
use crate::recover::{GenesisRecovery, RecoveryFile};
use libra_types::account_address::AccountAddress;
use std::path::PathBuf;
use vm_genesis::{OperRecover, ValRecover};

/// Make recovery file in format needed
pub fn make_recovery_file(recover: Vec<GenesisRecovery>, _output_path: PathBuf) {
    // read file
    let mut file = RecoveryFile::default();

    for i in &recover {
        let account: AccountAddress = i.account;
        // get deduplicated validators info
        match i.role {
            Validator => {
                let val_cfg = i.val_cfg.as_ref().unwrap().validator_config.as_ref().unwrap().clone();

                let operator_delegated_account = i.val_cfg.as_ref().unwrap().delegated_account.unwrap();
                // prevent duplicate accounts
                if file
                    .vals
                    .iter()
                    .find(|&a| a.val_account == account)
                    .is_none()
                {
                    file.vals.push(ValRecover {
                        val_account: account,
                        operator_delegated_account,
                        val_auth_key: i.auth_key.unwrap(),
                    });
                }

                // find the operator's authkey
                let oper_data = recover
                    .iter()
                    .find(|&a| a.account == operator_delegated_account && a.role == Operator);

                match oper_data {
                    Some(o) => {
                        // get the operator info, preventing duplicates
                        if file
                            .opers
                            .iter()
                            .find(|&a| a.operator_account == operator_delegated_account)
                            .is_none()
                        {
                            file.opers.push(OperRecover {
                                operator_account: o.account,
                                operator_auth_key: o.auth_key.unwrap(),
                                validator_to_represent: account,
                                // TODO: Check conversion of public key
                                operator_consensus_pubkey: val_cfg
                                    .consensus_public_key
                                    .to_bytes()
                                    .to_vec(),
                                validator_network_addresses: val_cfg.validator_network_addresses,
                                fullnode_network_addresses: val_cfg.fullnode_network_addresses,
                            });
                        }
                    }
                    None => todo!(),
                }
            }
            _ => {}
        }
        // get deduplicated operator info

        // file.vals.sort_by(|a, b| b.val_account.cmp(&a.val_account));
    }

    // get operators to recover
    // get vals to recover

    // Get a base gensis
    // let genesis = encode_recovery_genesis_transaction(recover, )?;

    // create transaction
    // save transaction
}
