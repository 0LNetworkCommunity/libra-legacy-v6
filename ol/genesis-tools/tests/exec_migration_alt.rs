//! Using the e2e test helpers we create a MoveVm session from fake data to be able to apply migrations
//! from Move system contracts. i.e. we don't craft the writesets
//! manually in rust, instead we execute functions in a Move session.
mod support;

// use support;
use std::fs;

use anyhow::Error;
use diem_framework_releases::current_module_blobs;
use diem_types::account_address::AccountAddress;
use diem_types::account_config;
use diem_types::transaction::Transaction;
use diem_types::transaction::WriteSetPayload::Direct;
use diem_types::write_set::WriteSet;
use diem_vm::convert_changeset_and_events;
use diem_vm::data_cache::StateViewCache;
use language_e2e_tests::data_store::FakeDataStore;
use move_binary_format::CompiledModule;
use move_bytecode_utils::Modules;
use move_core_types::identifier::Identifier;
use move_core_types::language_storage::ModuleId;
use move_core_types::language_storage::TypeTag;
use move_vm_runtime::move_vm::MoveVM;
use move_vm_runtime::session::Session;
use move_vm_types::gas_schedule::GasStatus;
use ol_genesis_tools::fork_genesis::make_recovery_genesis_from_vec_legacy_recovery;
use ol_genesis_tools::recover::LegacyRecovery;
use move_core_types::value::MoveValue;
use move_core_types::value::serialize_values;

#[test]
fn test_clean_genesis() {
    // use move_core_types::value::MoveValue;
    if let Transaction::GenesisTransaction(Direct(cs)) = get_gen_tx().unwrap() {
        let ws = cs.write_set();

        // create a fake data store for the move vm to use
        let mut storage = FakeDataStore::default();
        // add the genesis transaction to state
        storage.add_write_set(ws);

        let data_cache = StateViewCache::new(&storage);
        let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
        let mut session = move_vm.new_session(&data_cache);

        // session.execute_function(
        //   module,
        //   function_name,
        //   ty_args,
        //   args,
        //   gas_status
        // )
            // execute a demo transaction
    exec_function(&mut session,
      "DiemScripts",
      "demo_e2e",
      vec![],
      serialize_values(&vec![MoveValue::U64(11)])
    )
    };

    // // get a valid genesis from the e2e test helpers
    // let a = generate_genesis_change_set_for_testing(GenesisOptions::Compiled);
    // // create a fake data store for the move vm to use
    // let mut storage = FakeDataStore::default();
    // // add the genesis transaction to state
    // storage.add_write_set(tx.);
    // // create a move vm session
    // let data_cache = StateViewCache::new(&storage);
    // let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
    // let mut session = move_vm.new_session(&data_cache);

    // // execute a demo transaction
    // exec_function(&mut session,
    //   "DiemScripts",
    //   "demo_e2e",
    //   vec![],
    //   serialize_values(&vec![MoveValue::U64(11)])
    // )
}

fn get_gen_tx() -> Result<Transaction, Error> {
    let genesis_vals = vec!["ADCB1D42A46292AE89E938BD982F2867".parse().unwrap()];

    let json = support::path_utils::json_path()
        .parent()
        .unwrap()
        .join("single_json_entry.json");

    let json_str = fs::read_to_string(json.clone()).unwrap();
    let user_accounts: Vec<LegacyRecovery> = serde_json::from_str(&json_str).unwrap();

    // dbg!(&mock_val);

    let temp_genesis_blob_path = json.parent().unwrap().join("fork_genesis.blob");

    make_recovery_genesis_from_vec_legacy_recovery(
        user_accounts,
        genesis_vals.clone(),
        temp_genesis_blob_path.clone(),
        true,
        // TODO: add validators
    )
}
// pub fn get_clean_genesis() -> Result<WriteSet, Error> {
//     let storage = FakeDataStore::default();
//     let data_cache = StateViewCache::new(&storage);

//     let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
//     let mut session = move_vm.new_session(&data_cache);

//     let mut stdlib_modules = Vec::new();

//     for module_bytes in current_module_blobs() {
//     let module = CompiledModule::deserialize(module_bytes).unwrap();
//     // state_view.add_module(&module.self_id(), &module_bytes);
//     stdlib_modules.push(module)
//     }

//     publish_stdlib(&mut session, Modules::new(stdlib_modules.iter()));
//   // let a = test_helper_clean_genesis_modules_only()?;
//     let (changeset1, events1) = session.finish().unwrap();

//     let (write_set, _events) = convert_changeset_and_events(changeset1, events1).unwrap();
//     Ok(write_set)
// }

fn exec_function(
    session: &mut Session<'_, '_, StateViewCache<'_, FakeDataStore>>,
    module_name: &str,
    function_name: &str,
    ty_args: Vec<TypeTag>,
    args: Vec<Vec<u8>>,
) {
    session
        .execute_function(
            &ModuleId::new(
                account_config::CORE_CODE_ADDRESS,
                Identifier::new(module_name).unwrap(),
            ),
            &Identifier::new(function_name).unwrap(),
            ty_args,
            args,
            &mut GasStatus::new_unmetered(),
        )
        .unwrap_or_else(|e| {
            panic!(
                "Error calling {}.{}: {}",
                module_name,
                function_name,
                e.into_vm_status()
            )
        });
}

// /// Publish the standard library.
// fn publish_stdlib(session: &mut Session<'_, '_, StateViewCache<'_, FakeDataStore>>, stdlib: Modules<'_>) {
//     let dep_graph = stdlib.compute_dependency_graph();
//     let mut addr_opt: Option<AccountAddress> = None;
//     let modules = dep_graph
//         .compute_topological_order()
//         .unwrap()
//         .map(|m| {
//             let addr = *m.self_id().address();
//             if let Some(a) = addr_opt {
//               assert!(
//                   a == addr,
//                   "All genesis modules must be published under the same address, but found modules under both {} and {}",
//                   a.short_str_lossless(),
//                   addr.short_str_lossless()
//               );
//             } else {
//                 addr_opt = Some(addr)
//             }
//             let mut bytes = vec![];
//             m.serialize(&mut bytes).unwrap();
//             bytes
//         })
//         .collect::<Vec<Vec<u8>>>();
//     // TODO: allow genesis modules published under different addresses. supporting this while
//     // maintaining the topological order is challenging.
//     session
//         .publish_module_bundle(modules, addr_opt.unwrap(), &mut GasStatus::new_unmetered())
//         .unwrap_or_else(|e| panic!("Failure publishing modules {:?}", e));
// }
