use std::{
    fs,
    path::PathBuf,
    time::{SystemTime, UNIX_EPOCH},
};

use anyhow::Result;
use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_address::AccountAddress,
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
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct AncestrysUnit {
    account: AccountAddress,
    ancestry: Vec<AccountAddress>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct MakeWholeUnit {
    address: AccountAddress,
    value: f64,
}

fn _ol_autopay_migrate(path: PathBuf) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    let start = SystemTime::now();
    let now = start.duration_since(UNIX_EPOCH)?;
    let _microseconds = now.as_micros();

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        let args = vec![MoveValue::Signer(diem_root_address())];

        session
            .execute_function(
                &ModuleId::new(
                    account_config::CORE_CODE_ADDRESS,
                    Identifier::new("MigrateAutoPayBal").unwrap(),
                ),
                &Identifier::new("do_it").unwrap(),
                vec![],
                serialize_values(&args),
                &mut gas_status,
                &log_context,
            )
            .unwrap(); // TODO: don't use unwraps.
        Ok(())
    })
}

pub fn ol_vouch_migrate(path: PathBuf, val_set: Vec<AccountAddress>) -> Result<ChangeSet> {
    println!("\nmigrating validator vouch data");
    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    let start = SystemTime::now();
    let now = start.duration_since(UNIX_EPOCH)?;
    let _microseconds = now.as_micros();

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        val_set.clone().iter().for_each(|addr| {
            let args = vec![MoveValue::Signer(addr.to_owned())];

            session
                .execute_function(
                    &ModuleId::new(
                        account_config::CORE_CODE_ADDRESS,
                        Identifier::new("Vouch").unwrap(),
                    ),
                    &Identifier::new("init").unwrap(),
                    vec![],
                    serialize_values(&args),
                    &mut gas_status,
                    &log_context,
                )
                .unwrap(); // TODO: don't use unwraps.

            let args = vec![
                MoveValue::Signer(diem_root_address()),
                MoveValue::Address(addr.to_owned()),
                MoveValue::vector_address(val_set.clone()),
            ];

            session
                .execute_function(
                    &ModuleId::new(
                        account_config::CORE_CODE_ADDRESS,
                        Identifier::new("Vouch").unwrap(),
                    ),
                    &Identifier::new("vm_migrate").unwrap(),
                    vec![],
                    serialize_values(&args),
                    &mut gas_status,
                    &log_context,
                )
                .unwrap(); // TODO: don't use unwraps.
        });

        Ok(())
    })
}

pub fn ol_makewhole_migrate(path: PathBuf, payments: Vec<MakeWholeUnit>) -> Result<ChangeSet> {
    println!("\nmigrating make whole data");
    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        payments.iter().for_each(|p| {
            let scaled = f64::trunc(p.value * 1000000f64) as u64;

            let args = vec![
                MoveValue::Signer(diem_root_address()),
                MoveValue::Signer(p.address),
                MoveValue::U64(scaled),
                MoveValue::vector_u8("carpe underpayment".as_bytes().to_vec()),
            ];

            session
                .execute_function(
                    &ModuleId::new(
                        account_config::CORE_CODE_ADDRESS,
                        Identifier::new("MakeWhole").unwrap(),
                    ),
                    &Identifier::new("vm_offer_credit").unwrap(),
                    vec![],
                    serialize_values(&args),
                    &mut gas_status,
                    &log_context,
                )
                .unwrap(); // TODO: don't use unwraps.
        });

        Ok(())
    })
}

pub fn ol_ancestry_migrate(path: PathBuf, ancestry_vec: Vec<AncestrysUnit>) -> Result<ChangeSet> {
    println!("\nmigrating ancestry data");

    let db = DiemDebugger::db(path)?;
    let v = db.get_latest_version()?;

    db.run_session_at_version(v, None, |session| {
        let mut gas_status = GasStatus::new_unmetered();
        let log_context = NoContextLog::new();

        ancestry_vec.into_iter().for_each(|a| {
            let args = vec![
                MoveValue::Signer(diem_root_address()),
                MoveValue::Address(a.account),
                MoveValue::vector_address(a.ancestry),
            ];

            session
                .execute_function(
                    &ModuleId::new(
                        account_config::CORE_CODE_ADDRESS,
                        Identifier::new("Ancestry").unwrap(),
                    ),
                    &Identifier::new("migrate").unwrap(),
                    vec![],
                    serialize_values(&args),
                    &mut gas_status,
                    &log_context,
                )
                .unwrap(); // TODO: don't use unwraps.
        });

        Ok(())
    })
}

pub fn parse_ancestry_file(ancestry_file: PathBuf) -> Result<Vec<AncestrysUnit>> {
    let file = fs::File::open(ancestry_file).expect("file should open read only");

    let ancestry_vec: Vec<AncestrysUnit> =
        serde_json::from_reader(file).expect("file should be proper JSON");
    Ok(ancestry_vec)
}

pub fn parse_makewhole_file(makewhole_file: PathBuf) -> Result<Vec<MakeWholeUnit>> {
    let file = fs::File::open(makewhole_file).expect("file should open read only");

    let makewhole_vec: Vec<MakeWholeUnit> =
        serde_json::from_reader(file).expect("file should be proper JSON");
    Ok(makewhole_vec)
}
