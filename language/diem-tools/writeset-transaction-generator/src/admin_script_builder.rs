// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use anyhow::{Result, bail};
use cli::client_proxy::encode_stdlib_upgrade_transaction;

use diem_types::{
    account_address::AccountAddress,
    account_config::diem_root_address,
    transaction::{ChangeSet, Script, TransactionArgument, WriteSetPayload},
};
use handlebars::Handlebars;
use move_lang::{compiled_unit::CompiledUnit, shared::Flags};
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

//////// 0L ////////
/// helper function to triggeer a reconfig after a stdlib upgrade.
pub fn encode_upgrade_reconfig_script() -> WriteSetPayload {
    let mut script = template_path();
    script.push("upgrade_reconfig.move");

    WriteSetPayload::Script {
        script: Script::new(
            compile_script(script.to_str().unwrap().to_owned()),
            vec![],
            vec![],
        ),
        execute_as: diem_root_address(),
    }
}

/// create the upgrade payload INCLUDING the epoch reconfigure
pub fn encode_stdlib_upgrade() -> Result<WriteSetPayload> {
    
  // Take the stdlib upgrade change set.
    let stdlib_change = encode_stdlib_upgrade_transaction();


    // take the upgrade reconfig script WriteSet.
    match encode_upgrade_reconfig_script()  {
        WriteSetPayload::Direct(upgrade_cs) => {
              
        // add the reconfig changes to the stdlib upgrade changeset
        // NOTE theree should be no changes, we are mostly interested in the events emitted.

        // create a new meerged writeset payload with
        // a. stdlib upgrade appended with upgrade reconfig script changes
        // b. events from upgrade reconfig script.


          let mut stdlib_ws = stdlib_change.write_set().to_owned().into_mut();

          upgrade_cs
            .write_set()
            .to_owned()
            .into_mut()
            .get()
            .into_iter()
            .for_each(|item| {
              stdlib_ws.push(item)
            });
          

          let golden = WriteSetPayload::Direct(
            ChangeSet::new(
              stdlib_ws.freeze()?, 
              upgrade_cs.events().to_owned()
            )
          );

          Ok(golden)
        },
        WriteSetPayload::Script { execute_as: _, script: _ } => bail!("could not get upgrade reconfig payload"),
    }
}
// // Update WriteSet
// fn encode_stdlib_upgrade_transaction() -> ChangeSet {
//     let mut write_set = WriteSetMut::new(vec![]);
//     for module in diem_framework::modules() {
//         let mut bytes = vec![];
//         module.serialize(&mut bytes).unwrap();
//         write_set.push((
//             AccessPath::code_access_path(module.self_id()),
//             WriteOp::Value(bytes),
//         ));
//     }
//     ChangeSet::new(
//         write_set.freeze().expect("Failed to create writeset"),
//         vec![],
//     )
// }

/// This is a combination of writesets needed to rescue a stuck network
/// 1. Flash a new stdlib library writeset (assumes you've made changes to Move code).
/// 2. Appends a bulk_update of the validator set. This transaction emits a network reconfiguration event.
/// Note that for any db-bootstrapper writeset to work, one new epoch event (reconfiguration) needs to be present. That is accomplished in #2. If you were only to apply #1, you would need to craft an epoch reconfig event, and we provide a script upgrade_reconfig.move in the templates here. But again, for this merged writset we only want one.
/// For this operation to work MAKE SURE THE STDLIB HAS BEEN COMPILED BEFOREHAND.
pub fn encode_rescue_writeset(vals: Vec<AccountAddress>) -> Result<WriteSetPayload>{
    // get the stdlib changes through sdk magic
    let stdlib_cs = encode_stdlib_upgrade_transaction();

    // dive into the object to get the mutable writeset.
    let temp = stdlib_cs.write_set().to_owned();
    let mut stdlib_ws = temp.into_mut();

    // get the validator change payload.
    // let bulk_update_payload = encode_bulk_update_vals_payload(vals);

    // destructure and get actual changes on the validator
    match encode_bulk_update_vals_payload(vals) {
        WriteSetPayload::Direct(bulk_update_cs) => {
            let paths = bulk_update_cs
              .write_set()
              .to_owned()
              .into_mut()
              .get();

            // loop through the changes and push to writeset.
            paths.into_iter().for_each(|item| {
                stdlib_ws.push(item);
            });

            let frozen = stdlib_ws.freeze()?;

            
            let golden = WriteSetPayload::Direct(
              ChangeSet::new(
                frozen, 
                stdlib_cs.events().to_owned()
              )
            );
            Ok(golden)
        },
        WriteSetPayload::Script { execute_as: _, script: _ } => bail!("cannot get a validator update writeset"),
    }
}
