//! genesis-wrapper

use std::fs::File;
use std::io::Write;
use std::path::PathBuf;
use crate::process_snapshot::{db_backup_into_recovery_struct};

use anyhow::{Error};
// use diem_types::account_address::AccountAddress;
use diem_types::transaction::{Transaction, WriteSetPayload};
use indicatif::ProgressBar;
use ol_types::{legacy_recovery::{LegacyRecovery, recover_validator_configs}, OLProgress};
use vm_genesis::{encode_recovery_genesis_changeset, Validator};

/// Make a recovery genesis blob from archive
pub async fn make_recovery_genesis_from_db_backup(
    genesis_blob_path: PathBuf,
    archive_path: PathBuf,
    append: bool,
    genesis_vals: &[Validator],
) -> Result<Transaction, Error> {
    // get the legacy data from archive
    let recovery = db_backup_into_recovery_struct(&archive_path).await?;

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
    genesis_val_configs: &[Validator],
    genesis_blob_path: PathBuf,
    append_user_accounts: bool,
) -> Result<Transaction, Error> {
    // get consensus accounts
    let pb = ProgressBar::new(recovery.len() as u64)
    .with_style(OLProgress::spinner())
    .with_prefix("Migrating validator configs");

    let all_validator_configs = recover_validator_configs(recovery)?;
    pb.finish_and_clear();

    // For a real upgrade or fork, we want to include all user accounts.
    // this is the default.
    // Otherwise, we might need to just collect the validator accounts
    // for debugging or other test purposes.
    // let expected_len_all_users = recovery.len() as u64;
    let recovery_changeset = encode_recovery_genesis_changeset(
      &all_validator_configs.vals,
      &all_validator_configs.opers,
      genesis_val_configs,
      1, // mainnet
      append_user_accounts,
      recovery, // TODO: turn this into an option type
    )?;
    let gen_tx = Transaction::GenesisTransaction(WriteSetPayload::Direct(recovery_changeset));
    dbg!("hi");
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
    // let file_path = output_path.join("genesis").with_extension("blob");
    let mut file = File::create(output_path)?;
    let bytes = bcs::to_bytes(&gen_tx)?;
    file.write_all(&bytes)?;
    Ok(())
}
