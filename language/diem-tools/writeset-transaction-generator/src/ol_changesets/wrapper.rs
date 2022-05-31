use std::{
    path::PathBuf,
};

use anyhow::Result;
use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_config,
    transaction::{ChangeSet, TransactionArgument},
};
use move_core_types::{identifier::Identifier, language_storage::ModuleId, transaction_argument};
use move_vm_runtime::logging::NoContextLog;
use move_vm_types::gas_schedule::GasStatus;

pub struct FunctionWrapper {
    pub module_name: String,
    pub function_name: String,
    pub txn_args: Vec<TransactionArgument>,
}

/// Reads a DB, and creates a changeset from executing a simple function.
/// Note this uses the existing stdlib and state of the DB supplied.
/// To merge changesets note that the DB state needs to be the same with those changsets.
/// If the changesets depend on each other, they must be run in the same session, and THE ORDER MATTERS.

pub fn function_changeset_from_db(
    path: PathBuf,
    functions: Vec<FunctionWrapper>,
) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;

    let v = db.get_latest_version()?;
    dbg!(&v);
    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        functions.iter().for_each(|f| {
            session
                .execute_function(
                    &ModuleId::new(
                        account_config::CORE_CODE_ADDRESS,
                        Identifier::new(f.module_name.as_str()).unwrap(),
                    ),
                    &Identifier::new(f.function_name.as_str()).unwrap(),
                    vec![],
                    transaction_argument::convert_txn_args(&f.txn_args),
                    &mut gas_status,
                    &log_context,
                )
                .unwrap(); // todo remove this unwrap.
        });

        Ok(())
    })
}
