use std::{
    path::PathBuf,
    time::{SystemTime, UNIX_EPOCH},
};

use anyhow::{bail, Result};
use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_address::AccountAddress,
    account_config::{diem_root_address, NewEpochEvent},
    block_metadata::DiemBlockResource,
    contract_event::ContractEvent,
    transaction::{ChangeSet, TransactionArgument},
};
use move_core_types::{language_storage::TypeTag, move_resource::MoveStructType};
use ol_types::epoch_timer::EpochTimerResource;
use move_resource_viewer::AnnotatedMoveValue;

use crate::ol_changesets::wrapper::{self, FunctionWrapper};

// NOTE: all new "genesis" writesets to be applied on db-bootstrapper must emit
// a reconfig NewEpochEvent. However. The Diemconfig::reconfig_ has a naive
// implementation of deduplication of reconfig events it checks that the current
// time is NOT equal to the last reconfig time.
// For db backups/snapshots using the backup-cli, the archives are generally
// made at an epoch boundary. And as such the timestamp will be identical to
// the last reconfiguration time, and ANY WRITESET USING DB-BOOTSTRAPPER WILL FAIL.
// This function is used to force a new timestamp in those cases, so that
// writesets will trigger reconfigs (if that is what is expected/intended).

pub fn ol_bulk_validators_changeset(path: PathBuf, vals: Vec<AccountAddress>) -> Result<ChangeSet> {
    println!("\nencode validators bulk update changeset");

    let txn_args = vec![
        TransactionArgument::Address(diem_root_address()),
        TransactionArgument::AddressVector(vals),
    ];

    let fnwrap = FunctionWrapper {
        module_name: "DiemSystem".to_string(),
        function_name: "bulk_update_validators".to_string(),
        txn_args,
    };

    wrapper::function_changeset_from_db(path, vec![fnwrap])
}

pub fn ol_reconfig_changeset(path: PathBuf) -> Result<ChangeSet> {
    let height_now = ol_get_internal_blockheight(path.clone())?;
    let txn_args = vec![
        TransactionArgument::Address(diem_root_address()),
        TransactionArgument::U64(height_now),
    ];

    let fnwrap = FunctionWrapper {
        module_name: "EpochBoundary".to_string(),
        function_name: "reconfigure".to_string(),
        txn_args,
    };

    wrapper::function_changeset_from_db(path, vec![fnwrap])
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


// TODO this doesn't work. Causes issues with epoch seq number already being bumped.
pub fn ol_reset_epoch_counters(
    path: PathBuf,
    vals: Vec<AccountAddress>,
) -> Result<ChangeSet> {
    let block_height = ol_get_internal_blockheight(path.clone())?;
    let txn_args = vec![
        TransactionArgument::Address(diem_root_address()),
        TransactionArgument::AddressVector(vals), // new validator set
        TransactionArgument::AddressVector(vec![]), // outgoing compliant
        TransactionArgument::U64(block_height + 1), // start of epoch
    ];

    let fnwrap = FunctionWrapper {
        module_name: "EpochBoundary".to_string(),
        function_name: "reset_counters".to_string(),
        txn_args,
    };

    wrapper::function_changeset_from_db(path, vec![fnwrap])
}

pub fn _ol_expire_oracle_upgrade(path: PathBuf) -> Result<ChangeSet> {
    let txn_args = vec![
        TransactionArgument::Address(diem_root_address()),
    ];

    let fnwrap = FunctionWrapper {
        module_name: "Oracle".to_string(),
        function_name: "vm_expire_upgrade".to_string(),
        txn_args,
    };

    wrapper::function_changeset_from_db(path, vec![fnwrap])
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


pub fn ol_increment_timestamp(path: PathBuf) -> Result<ChangeSet> {
    let start = SystemTime::now();
    let now = start.duration_since(UNIX_EPOCH)?;
    let microseconds = now.as_micros();

    let txn_args = vec![
        TransactionArgument::Address(diem_root_address()),
        TransactionArgument::Address(AccountAddress::random()),
        TransactionArgument::U64(microseconds as u64),
    ];

    let fnwrap = FunctionWrapper {
        module_name: "DiemTimestamp".to_string(),
        function_name: "update_global_time".to_string(),
        txn_args,
    };

    wrapper::function_changeset_from_db(path, vec![fnwrap])
}

fn ol_get_internal_blockheight(path: PathBuf) -> Result<u64> {
    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    // TODO: HELP! there must be a better way to get a MoveResource from db
    if let Some(acc) = db.annotate_account_state_at_version(AccountAddress::ZERO, v, false)? {
        let key = DiemBlockResource::struct_tag();
        let move_str = acc
            .0
            .get(&key)
            .expect("cannot get a value for DiemBlockResource");

        // confirm the field exists.
        let height = move_str.value.iter().find_map(|item| {
            if let AnnotatedMoveValue::U64(u) = item.1 {
                match item.0.as_str() {
                    "height" => Some(u),
                    _ => None,
                }
            } else {
                None
            }
        });

        match height {
            Some(h) => return Ok(h),
            None => bail!("could not get internal block height"),
        }
    };

    bail!("could not get epoch height")
}