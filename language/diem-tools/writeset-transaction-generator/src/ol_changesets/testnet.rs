use std::path::PathBuf;

use anyhow::Result;
use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_config::{self, diem_root_address},
    transaction::ChangeSet,
};
use move_core_types::{
    identifier::Identifier,
    language_storage::ModuleId,
    value::{serialize_values, MoveValue},
};
use move_vm_runtime::logging::NoContextLog;
use move_vm_types::gas_schedule::GasStatus;

pub fn ol_testnet_changeset(path: PathBuf) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;

    let v = db.get_latest_version()?;
    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        let args = vec![MoveValue::Signer(diem_root_address())];

        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("Testnet").unwrap(),
                ),
                &Identifier::new("initialize").unwrap(),
                vec![],
                serialize_values(&args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // TODO: don't use unwraps.
        Ok(())
    })
}

pub fn ol_staging_net_changeset(path: PathBuf) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;

    let v = db.get_latest_version()?;
    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        let args = vec![MoveValue::Signer(diem_root_address())];

        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("StagingNet").unwrap(),
                ),
                &Identifier::new("initialize").unwrap(),
                vec![],
                serialize_values(&args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // TODO: don't use unwraps.
        Ok(())
    })
}
