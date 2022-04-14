// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use anyhow::{Result};
use cli::client_proxy::encode_stdlib_upgrade_transaction;

use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_address::AccountAddress,
    account_config::{self, diem_root_address},
    transaction::{ChangeSet, Script, TransactionArgument, WriteSetPayload},
};

use handlebars::Handlebars;
use move_core_types::{
    identifier::Identifier,
    language_storage::ModuleId,
    value::{serialize_values, MoveValue}, transaction_argument::convert_txn_args,
};

use move_lang::{compiled_unit::CompiledUnit, shared::Flags};
use move_vm_runtime::logging::NoContextLog;
use move_vm_types::gas_schedule::GasStatus;
use serde::Serialize;
use std::{collections::HashMap, io::Write, path::PathBuf, process::exit};
use tempfile::NamedTempFile;

/// The relative path to the scripts templates
pub const SCRIPTS_DIR_PATH: &str = "templates";

pub fn compile_script(source_file_str: String) -> Vec<u8> {
    let (_files, mut compiled_program) = move_lang::move_compile_and_report(
        &[source_file_str],
        &diem_framework::diem_stdlib_files(),
        None,
        Flags::empty().set_sources_shadow_deps(false),
    )
    .unwrap();
    let mut script_bytes = vec![];
    assert!(compiled_program.len() == 1);
    match compiled_program.pop().unwrap() {
        CompiledUnit::Module { .. } => panic!("Unexpected module when compiling script"),
        CompiledUnit::Script { script, .. } => script.serialize(&mut script_bytes).unwrap(),
    };
    script_bytes
}

fn compile_admin_script(input: &str) -> Result<Script> {
    let mut temp_file = NamedTempFile::new()?;
    temp_file.write_all(input.as_bytes())?;
    let cur_path = temp_file.path().to_str().unwrap().to_owned();
    Ok(Script::new(compile_script(cur_path), vec![], vec![]))
}

pub fn template_path() -> PathBuf {
    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.push(SCRIPTS_DIR_PATH.to_string());
    path
}

pub fn encode_remove_validators_payload(validators: Vec<AccountAddress>) -> WriteSetPayload {
    assert!(!validators.is_empty(), "Unexpected validator set length");
    let mut script = template_path();
    script.push("remove_validators.move");

    let script = {
        let mut hb = Handlebars::new();
        hb.set_strict_mode(true);
        hb.register_template_file("script", script).unwrap();
        let mut data = HashMap::new();
        data.insert("addresses", validators);

        let output = hb.render("script", &data).unwrap();

        compile_admin_script(output.as_str()).unwrap()
    };

    WriteSetPayload::Script {
        script,
        execute_as: diem_root_address(),
    }
}

pub fn encode_custom_script<T: Serialize>(
    script_name_in_templates: &str,
    args: &T,
    execute_as: Option<AccountAddress>,
) -> WriteSetPayload {
    let mut script = template_path();
    script.push(script_name_in_templates);

    let script = {
        let mut hb = Handlebars::new();
        hb.register_template_file("script", script).unwrap();
        hb.set_strict_mode(true);
        let output = hb.render("script", args).unwrap();

        compile_admin_script(output.as_str()).unwrap()
    };

    WriteSetPayload::Script {
        script,
        execute_as: execute_as.unwrap_or_else(diem_root_address),
    }
}

pub fn encode_halt_network_payload() -> WriteSetPayload {
    let mut script = template_path();
    script.push("halt_transactions.move");

    WriteSetPayload::Script {
        script: Script::new(
            compile_script(script.to_str().unwrap().to_owned()),
            vec![],
            vec![],
        ),
        execute_as: diem_root_address(),
    }
}

//////// 0L ////////
pub fn encode_bulk_update_vals_payload(vals: Vec<AccountAddress>) -> WriteSetPayload {
    let mut script = template_path();
    script.push("bulk_update.move");

    WriteSetPayload::Script {
        script: Script::new(
            compile_script(script.to_str().unwrap().to_owned()),
            vec![],
            vec![TransactionArgument::AddressVector(vals)],
        ),
        execute_as: diem_root_address(),
    }
}



/// create the upgrade payload INCLUDING the epoch reconfigure
pub fn encode_stdlib_upgrade(path: PathBuf) -> WriteSetPayload {
    // Take the stdlib upgrade change set.
    let stdlib_cs = encode_stdlib_upgrade_transaction();

    let reconfig = ol_reconfig_changeset(path).unwrap();

    WriteSetPayload::Direct(merge_change_set(stdlib_cs, reconfig).unwrap())
}

/// create the upgrade payload INCLUDING the epoch reconfigure
pub fn ol_encode_rescue(path: PathBuf, vals: Vec<AccountAddress>) -> WriteSetPayload {
    if vals.len() == 0 { println!("need to provide list of addresses"); exit(1)};

    let stdlib_cs = encode_stdlib_upgrade_transaction();

    // Take the stdlib upgrade change set.
    let update_vals = ol_bulk_validators_changeset(path, vals).unwrap();

    WriteSetPayload::Direct(merge_change_set(stdlib_cs, update_vals).unwrap())
}

fn merge_change_set(left: ChangeSet, right: ChangeSet) -> Result<ChangeSet>{
    // get stlib_cs writeset mut and apply reconfig changeset over it
    let mut stdlib_ws_mut = left.write_set().clone().into_mut();

    let r_ws = right.write_set().clone().into_mut();
    
    r_ws.get().into_iter()
    .for_each(|item|{
      stdlib_ws_mut.push(item)
    });

    let mut all_events = left.events().to_owned().clone();
    let mut reconfig_events = right.events().to_owned().clone();
    all_events.append(&mut reconfig_events);

    let new_cs = ChangeSet::new(
      stdlib_ws_mut.freeze()?, 
      all_events
    );

    Ok(new_cs)
}



pub fn ol_create_reconfig_payload(path: PathBuf) -> WriteSetPayload {

    WriteSetPayload::Direct(ol_reconfig_changeset(path).expect("could not create reconfig change set"))
}

fn ol_bulk_validators_changeset(path: PathBuf, vals: Vec<AccountAddress>) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;

    
    let v = db.get_latest_version()?;
    db.run_session_at_version(
      v, 
      None, 
      |session| {
          let mut gas_status = GasStatus::new_unmetered();
          let log_context = NoContextLog::new();

          let txn_args = vec![
            TransactionArgument::Address(diem_root_address()),
            TransactionArgument::AddressVector(vals)
          ];
          session.execute_function(
            &ModuleId::new(
              account_config::CORE_CODE_ADDRESS, Identifier::new("DiemSystem").unwrap()
              ),
            &Identifier::new("bulk_update_validators").unwrap(), 
            vec![], 
            convert_txn_args(&txn_args), 
             &mut gas_status,
             &log_context
            ).unwrap(); // todo remove this unwrap.
          Ok(())
      })
}


fn ol_reconfig_changeset(path: PathBuf) -> Result<ChangeSet> {
    let db = DiemDebugger::db(path)?;

    let v = db.get_latest_version()?;
    db.run_session_at_version(
      v, 
      None, 
      |session| {
          let mut gas_status = GasStatus::new_unmetered();
          let log_context = NoContextLog::new();

          let args = vec![MoveValue::Signer(diem_root_address())];

          session.execute_function(
              &ModuleId::new(account_config::CORE_CODE_ADDRESS, Identifier::new("DiemConfig").unwrap()),
              &Identifier::new("upgrade_reconfig").unwrap(),
              vec![],
              serialize_values(&args),
              &mut gas_status,
              &log_context,
          ).unwrap(); // TODO: don't use unwraps.
          Ok(())
      })
}
