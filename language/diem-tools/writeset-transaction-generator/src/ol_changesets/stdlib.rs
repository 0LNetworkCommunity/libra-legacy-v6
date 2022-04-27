use std::path::PathBuf;

use anyhow::Result;
use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_address::AccountAddress,
    account_config::{self, diem_root_address},
    transaction::{ChangeSet, TransactionArgument},
};
use move_core_types::{
    identifier::Identifier, language_storage::ModuleId, transaction_argument::convert_txn_args,
};
use move_vm_runtime::logging::NoContextLog;
use move_vm_types::gas_schedule::GasStatus;

pub fn ol_fresh_stlib_changeset(path: PathBuf) -> Result<ChangeSet> {
    println!("\nencode stdlib changeset");

    let db = DiemDebugger::db(path)?;

    // publish the agreed stdlib
    let new_stdlib = diem_framework::modules();

    let v = db.get_latest_version()?;
    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        for module in new_stdlib {
            let mut bytes = vec![];
            module.serialize(&mut bytes).unwrap();

            session
                .revise_module(
                    bytes,
                    account_config::CORE_CODE_ADDRESS,
                    &mut gas_status,
                    &log_context,
                )
                .unwrap()
        }
        Ok(())
    })
}

pub fn ol_set_epoch_recovery_mode(
    path: PathBuf,
    vals: Vec<AccountAddress>,
    end_epoch: u64,
) -> Result<ChangeSet> {
  // TODO: this could be done with the wrapper.

    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        // first we remove the recovery mode in case it has been set, so we
        // make sure it has the properties we want.

        let txn_args = vec![TransactionArgument::Address(diem_root_address())];
        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("RecoveryMode").unwrap(),
                ),
                &Identifier::new("remove_debug").unwrap(),
                vec![],
                convert_txn_args(&txn_args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // todo remove this unwrap.

        let txn_args = vec![
            TransactionArgument::Address(diem_root_address()),
            TransactionArgument::AddressVector(vals),
            TransactionArgument::U64(end_epoch),
        ];

        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("RecoveryMode").unwrap(),
                ),
                &Identifier::new("init_recovery").unwrap(),
                vec![],
                convert_txn_args(&txn_args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // todo remove this unwrap.
        Ok(())
    })
}
