//! genesis-wrapper

use std::fs::File;
use std::io::Write;
use std::path::PathBuf;
use crate::process_snapshot::{db_backup_into_recovery_struct};

use anyhow::{Error};
use diem_types::account_address::AccountAddress;
use diem_types::transaction::{Transaction, WriteSetPayload};
use ol_types::legacy_recovery::{LegacyRecovery, recover_validator_configs};
use vm_genesis::encode_recovery_genesis_changeset;

/// Make a recovery genesis blob from archive
pub async fn make_recovery_genesis_from_db_backup(
    genesis_blob_path: PathBuf,
    archive_path: PathBuf,
    append: bool,
    is_legacy: bool,
    genesis_vals: Vec<AccountAddress>,
) -> Result<Transaction, Error> {
    // get the legacy data from archive
    let recovery = db_backup_into_recovery_struct(&archive_path, is_legacy).await?;

    make_recovery_genesis_from_vec_legacy_recovery(
      &recovery, 
      genesis_vals,
      genesis_blob_path, 
      append
    )
}

/// Make a recovery genesis blob
pub fn make_recovery_genesis_from_vec_legacy_recovery(
    recovery: &[LegacyRecovery],
    genesis_vals: Vec<AccountAddress>,
    genesis_blob_path: PathBuf,
    append_user_accounts: bool,
) -> Result<Transaction, Error> {
    // get consensus accounts
    let all_validator_configs = recover_validator_configs(recovery)?;

    // check the validators that are joining genesis actually have legacy data
    let count = all_validator_configs.vals
    .iter()
    .filter(
      |v| {
        genesis_vals.contains(&v.val_account)
      }
    )
    .count();

    if count == 0 {
      anyhow::bail!("no val configs found for genesis set");
    }

    // we use the vm-genesis to properly migrate EVERY validator account.
    // then we select a subset which will be the validators of the first epoch.
    // let genesis_changeset_with_validators = get_baseline_genesis_change_set(all_validator_configs, &genesis_vals)?;

    let recovery_changeset = encode_recovery_genesis_changeset(
      &all_validator_configs.vals,
      &all_validator_configs.opers,
      &genesis_vals,
      1, // mainnet
      append_user_accounts,
      recovery, // TODO: turn this into an option type
    )?;

    // For a real upgrade or fork, we want to include all user accounts.
    // this is the default.
    // Otherwise, we might need to just collect the validator accounts
    // for debugging or other test purposes.
    // let expected_len_all_users = recovery.len() as u64;

    // let gen_tx = if append_user_accounts {
    //     // append further writeset to genesis
    //     append_genesis(
    //       genesis_changeset_with_validators,
    //       recovery,
    //       expected_len_all_users
    //     )?
    // } else {
    let gen_tx = Transaction::GenesisTransaction(WriteSetPayload::Direct(recovery_changeset));
    // };
    // save genesis
    save_genesis(&gen_tx, genesis_blob_path)?;

    Ok(gen_tx)
}

// /// Get the minimal viable genesis from consensus accounts.
// pub fn get_baseline_genesis_change_set(
//     genesis_accounts: RecoverConsensusAccounts,
//     validator_set: &[AccountAddress],
// ) -> Result<ChangeSet, Error> {
//     encode_recovery_genesis_changeset(
//         &genesis_accounts.vals,
//         &genesis_accounts.opers,
//         &validator_set,
//         1, // mainnet
//         false,
//         vec![],

//     )
// }



/// save the genesis blob
pub fn save_genesis(gen_tx: &Transaction, output_path: PathBuf) -> Result<(), Error> {
    let mut file = File::create(output_path)?;
    let bytes = bcs::to_bytes(&gen_tx)?;
    file.write_all(&bytes)?;
    Ok(())
}
