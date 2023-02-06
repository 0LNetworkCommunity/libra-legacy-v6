//! functions for comparing LegacyRecovery data to a genesis blob
//! every day is like sunday
//! -- morrissey via github copilot

use crate::db_utils;
use crate::recover;
use crate::recover::LegacyRecovery;
use anyhow;
use diem_types::account_state::AccountState;
use std::convert::TryFrom;
use std::path::PathBuf;

/// Compare the balances in a recovery file to the balances in a genesis blob.
pub fn compare_recovery_vec_to_genesis_blob(
    recovery: Vec<LegacyRecovery>,
    genesis_path: PathBuf,
) -> Result<(), anyhow::Error> {
    // iterate over the recovery file and compare balances
    let (db_rw, _) = db_utils::read_db_and_compute_genesis(genesis_path)?;

    recovery.into_iter().for_each(|v| {
        if v.account.is_none() {
            return;
        }; //TODO: make this raise error

        let val_state = db_rw
            .reader
            .get_latest_account_state(v.account.expect("need an address"))
            .expect("get account state")
            .expect("option is None");

        let account_state = AccountState::try_from(&val_state).unwrap();

        let bal = account_state.get_balance_resources().unwrap();

        dbg!(&bal);
    });

    Ok(())
}

/// Compare the balances in a recovery file to the balances in a genesis blob.
pub fn compare_json_to_genesis_blob(
    json_path: PathBuf,
    genesis_path: PathBuf,
) -> Result<(), anyhow::Error> {
    let recovery = recover::read_from_recovery_file(&json_path);
    compare_recovery_vec_to_genesis_blob(recovery, genesis_path)
}
