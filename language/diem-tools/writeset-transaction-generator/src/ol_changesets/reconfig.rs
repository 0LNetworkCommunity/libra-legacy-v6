use std::{
    path::PathBuf,
    time::{SystemTime, UNIX_EPOCH},
};

use anyhow::{bail, Result};
use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_address::AccountAddress,
    account_config::{self, diem_root_address, NewEpochEvent},
    contract_event::ContractEvent,
    transaction::{ChangeSet, TransactionArgument},
};
use move_core_types::{
    identifier::Identifier,
    language_storage::{ModuleId, TypeTag},
    move_resource::MoveStructType,
    transaction_argument::convert_txn_args,
    value::{serialize_values, MoveValue},
};
use move_vm_runtime::logging::NoContextLog;
use move_vm_types::gas_schedule::GasStatus;
use ol_types::epoch_timer::EpochTimerResource;
use resource_viewer::AnnotatedMoveValue;

// NOTE: all new "genesis" writesets to be applied on db-bootstrapper must emit a reconfig NewEpochEvent.
// However. The Diemconfig::reconfig_ has a naive implementation of deduplication of reconfig events it checks that the current time is NOT equal to the last reconfig time.
// For db backups/snapshots using the backup-cli, the archives are generally made at an epoch boundary. And as such the timestamp will be identical to the last reconfiguration time, and ANY WRITESET USING DB-BOOTSTRAPPER WILL FAIL.
// This function is used to force a new timestamp in those cases, so that writesets will trigger reconfigs (if that is what is expected/intended).

pub fn ol_bulk_validators_changeset(path: PathBuf, vals: Vec<AccountAddress>) -> Result<ChangeSet> {
    println!("\nencode validators bulk update changeset");
    let db = DiemDebugger::db(path)?;

    let v = db.get_latest_version()?;
    dbg!(&v);
    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        let txn_args = vec![
            TransactionArgument::Address(diem_root_address()),
            TransactionArgument::AddressVector(vals),
        ];
        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("DiemSystem").unwrap(),
                ),
                &Identifier::new("bulk_update_validators").unwrap(),
                vec![],
                convert_txn_args(&txn_args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // todo remove this unwrap.
        Ok(())
    })
}

pub fn ol_reconfig_changeset(path: PathBuf, height_now: u64) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;

    let v = db.get_latest_version()?;
    let cs = db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        let args = vec![
            MoveValue::Signer(diem_root_address()),
            MoveValue::U64(height_now),
        ];

        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("EpochBoundary").unwrap(),
                ),
                &Identifier::new("reconfigure").unwrap(),
                vec![],
                serialize_values(&args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // TODO: don't use unwraps.
        Ok(())
    })?;
    // dbg!(&cs.events().len());

    let old_event = cs.events().first().unwrap();
    let epoch_change = read_epoch_event(&cs)?;

    let new_ce = mfg_epoch_event(epoch_change.epoch(), old_event.sequence_number())?;

    let new_change_set = ChangeSet::new(cs.write_set().to_owned(), vec![new_ce]);

    new_change_set.events().iter().for_each(|e| {
        // dbg!(&e);
        dbg!(&e.sequence_number());
    });

    Ok(cs)
}

pub fn mfg_epoch_event(epoch: u64, seq: u64) -> Result<ContractEvent> {
    let new_event = NewEpochEvent::new(epoch);

    dbg!(&new_event.epoch());

    Ok(ContractEvent::new(
        NewEpochEvent::event_key(),
        seq,
        TypeTag::Struct(NewEpochEvent::struct_tag()),
        bcs::to_bytes(&new_event)?,
    ))
}

fn read_epoch_event(cs: &ChangeSet) -> Result<NewEpochEvent> {
    let event = cs.events().first().unwrap();
    NewEpochEvent::try_from_bytes(event.event_data())
}

// TODO this doesn't work.
pub fn ol_force_boundary(
    path: PathBuf,
    vals: Vec<AccountAddress>,
    block_height: u64,
) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;

    // TODO: This is not producing the same version height after appling to database.
    let v = db.get_latest_version()?;

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        // fun reset_counters(vm: &signer, proposed_set: vector<address>, outgoing_compliant: vector<address>, height_now: u64) {

        let args = vec![
            MoveValue::Signer(diem_root_address()),
            MoveValue::vector_address(vals),   // proposed_set
            MoveValue::vector_address(vec![]), // outgoing_compliant
            MoveValue::U64(block_height + 1),  // height_now
        ];

        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("EpochBoundary").unwrap(),
                ),
                &Identifier::new("reset_counters").unwrap(),
                vec![],
                serialize_values(&args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // TODO: don't use unwraps.
        Ok(())
    })
}

pub fn ol_epoch_timestamp_update(path: PathBuf) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    let start = SystemTime::now();
    let now = start.duration_since(UNIX_EPOCH)?;
    let microseconds_now = now.as_micros();

    if let Some(acc) = db.annotate_account_state_at_version(AccountAddress::ZERO, v, false)? {
        let key = EpochTimerResource::struct_tag();
        // confirm the field exists.
        if let Some(v) = acc.0.get(&key) {
            // dbg!(&v);
            let mut e = EpochTimerResource {
                epoch: 0,
                height_start: 0,
                seconds_start: microseconds_now as u64,
            };

            v.value.iter().for_each(|item| {
                if let AnnotatedMoveValue::U64(u) = item.1 {
                    match item.0.as_str() {
                        "epoch" => e.epoch = u,
                        "height_start" => e.height_start = u,
                        // "seconds_start" => e.seconds_start = u,
                        _ => {}
                    }
                };
            });

            dbg!(&e);
            let cs = ChangeSet::new(e.to_writeset()?.freeze()?, vec![]);
            return Ok(cs);
        }
    };

    bail!("could not get epoch timer state")
}

#[test]
fn test_epoch() {
    ol_epoch_timestamp_update("/home/node/.0L/db".parse().unwrap());
}

pub fn ol_increment_timestamp(path: PathBuf) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    let start = SystemTime::now();
    let now = start.duration_since(UNIX_EPOCH)?;
    let microseconds = now.as_micros();

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        let txn_args = vec![
            TransactionArgument::Address(diem_root_address()),
            TransactionArgument::Address(AccountAddress::random()),
            TransactionArgument::U64(microseconds as u64),
        ];
        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("DiemTimestamp").unwrap(),
                ),
                &Identifier::new("update_global_time").unwrap(),
                vec![],
                convert_txn_args(&txn_args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // todo remove this unwrap.

        let args = vec![MoveValue::Signer(diem_root_address())];

        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("DiemConfig").unwrap(),
                ),
                &Identifier::new("upgrade_reconfig").unwrap(),
                vec![],
                serialize_values(&args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // TODO: don't use unwraps.
        Ok(())
    })
}

fn _ol_increment_timestamp_changeset(path: PathBuf) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    let start = SystemTime::now();
    let now = start.duration_since(UNIX_EPOCH)?;
    let microseconds = now.as_micros();

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        let txn_args = vec![
            TransactionArgument::Address(diem_root_address()),
            TransactionArgument::Address("46A7A744B5D33C47F6B20766F8088B10".parse().unwrap()),
            TransactionArgument::U64(microseconds as u64),
        ];
        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("DiemTimestamp").unwrap(),
                ),
                &Identifier::new("update_global_time").unwrap(),
                vec![],
                convert_txn_args(&txn_args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // todo remove this unwrap.

        Ok(())
    })
}
