// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use anyhow::{Result};
use cli::client_proxy::encode_stdlib_upgrade_transaction;

use diem_transaction_replay::DiemDebugger;
use diem_types::{
    account_address::AccountAddress,
    account_config::{self, diem_root_address, NewEpochEvent},
    contract_event::ContractEvent,
    transaction::{ChangeSet, Script, TransactionArgument, WriteSetPayload},
};

use handlebars::Handlebars;
use move_core_types::{
    identifier::Identifier,
    language_storage::ModuleId,
    move_resource::MoveStructType,
    value::{serialize_values, MoveValue},
};
use move_core_types::{language_storage::TypeTag};
use move_lang::{compiled_unit::CompiledUnit, shared::Flags};
use move_vm_runtime::logging::NoContextLog;
use move_vm_types::gas_schedule::GasStatus;
use serde::Serialize;
use std::{collections::HashMap, io::Write, path::PathBuf};
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
// }
//     // let event = NewEpochEvent::new(50000);
// pub fn encode_stdlib_upgrade(path: PathBuf) -> WriteSetPayload {
    let reconfig = ol_reconfig_changeset(path).unwrap();

    let new_cs = ChangeSet::new(stdlib_cs.write_set().to_owned(), reconfig.events().to_vec());

    WriteSetPayload::Direct(new_cs)
}



pub fn ol_create_reconfig_payload(path: PathBuf) -> WriteSetPayload {

    WriteSetPayload::Direct(ol_reconfig_changeset(path).expect("could not create reconfig change set"))
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

// pub fn encode_halt_network_payload() -> WriteSetPayload {
//     let mut script = template_path();
//     script.push("halt_transactions.move");

//     WriteSetPayload::Script {
//         script: Script::new(
//             compile_script(script.to_str().unwrap().to_owned()),
//             vec![],
//             vec![],
//         ),
//         execute_as: diem_root_address(),
//     }
// }


// TransactionPayload::WriteSet(WriteSetPayload::Direct(
//                     encode_stdlib_upgrade_transaction()

// fn mock_new_epoch_event(epoch: u64) -> ContractEvent {
//     let key = NewEpochEvent::event_key(); // TODO
//     let sequence_number = epoch;
//     // let type_tag = move_core_types::language_storage::TypeTag::Struct(());

//     let e = NewEpochEvent::new(epoch + 1);
//     let type_tag = TypeTag::Struct(NewEpochEvent::struct_tag());
//     let event_data = bcs::to_bytes(&e).unwrap();

//     // StructTag

//     ContractEvent::new(key, sequence_number, type_tag, event_data)
// }