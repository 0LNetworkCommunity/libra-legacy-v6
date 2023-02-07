//! Using the e2e test helpers we create a MoveVm session from fake data to be able to apply migrations
//! from Move system contracts. i.e. we don't craft the writesets
//! manually in rust, instead we execute functions in a Move session.

// use crate::ol_genesis_context;
use crate::recover::LegacyRecovery;
use anyhow::Error;
use diem_framework_releases::current_module_blobs;
use diem_types::PeerId;
use diem_types::account_config;
use diem_types::contract_event;
use diem_types::write_set::WriteSet;
use diem_types::write_set::WriteSetMut;
use language_e2e_tests::data_store::FakeDataStore;
use language_e2e_tests::executor::FakeExecutor;
use move_binary_format::CompiledModule;
use move_core_types::{
    language_storage::TypeTag,
    value::{serialize_values, MoveValue},
};
use diem_types::transaction::ChangeSet;
use diem_vm::data_cache::StateViewCache;
use diem_vm::convert_changeset_and_events;
use move_vm_runtime::move_vm::MoveVM;
use move_bytecode_utils::Modules;
use vm_genesis::test_helper_clean_genesis_modules_only;

use move_vm_runtime::session::Session;
use diem_types::account_address::AccountAddress;
use move_vm_types::gas_schedule::GasStatus;

#[test]
pub fn test_changes_to_clean_genesis(){
    let storage = FakeDataStore::default();
    let data_cache = StateViewCache::new(&storage);

    let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
    let mut session = move_vm.new_session(&data_cache);
    
    let mut stdlib_modules = Vec::new();

    for module_bytes in current_module_blobs() {
    let module = CompiledModule::deserialize(module_bytes).unwrap();
    // state_view.add_module(&module.self_id(), &module_bytes);
    stdlib_modules.push(module)
    }

    publish_stdlib(&mut session, Modules::new(stdlib_modules.iter()));
  // let a = test_helper_clean_genesis_modules_only()?;
    let (changeset1, events1) = session.finish().unwrap();

    // Ok(changeset1)
    // generate_genesis_change_set_for_testing_ol

    // let mut stdlib_modules = Vec::new();
    // // create a data view for move_vm
    // let mut state_view = ol_genesis_context::GenesisStateView::new();
    // for module_bytes in diem_framework_releases::current_module_blobs() {
    //     let module = move_binary_format::CompiledModule::deserialize(module_bytes).unwrap();
    //     state_view.add_module(&module.self_id(), &module_bytes);
    //     stdlib_modules.push(module)
    // }
    // let data_cache = StateViewCache::new(&state_view);

    // let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
    // let mut session = move_vm.new_session(&data_cache);

    // let (mut changeset1, mut events1) = session.finish().unwrap();

    // // TODO: is this necessary?
    // let state_view = ol_genesis_context::GenesisStateView::new();
    // let data_cache = StateViewCache::new(&state_view);
    // let mut session = move_vm.new_session(&data_cache);
    // // end Todo
    // vm_genesis::publish_stdlib(&mut session, Modules::new(stdlib_modules.iter()));

    // let (changeset2, events2) = session.finish().unwrap();

    // changeset1.squash(changeset2).unwrap();
    // events1.extend(events2);

    // let (write_set, events) = convert_changeset_and_events(changeset1, events1).unwrap();

    // assert!(!write_set.iter().any(|(_, op)| op.is_deletion()));
    // verify_genesis_write_set(&events);
    // Ok(ChangeSet::new(write_set, events))
}



/// Publish the standard library.
fn publish_stdlib(session: &mut Session<StateViewCache<FakeDataStore>>, stdlib: Modules) {
    let dep_graph = stdlib.compute_dependency_graph();
    let mut addr_opt: Option<AccountAddress> = None;
    let modules = dep_graph
        .compute_topological_order()
        .unwrap()
        .map(|m| {
            let addr = *m.self_id().address();
            if let Some(a) = addr_opt {
              assert!(
                  a == addr,
                  "All genesis modules must be published under the same address, but found modules under both {} and {}",
                  a.short_str_lossless(),
                  addr.short_str_lossless()
              );
            } else {
                addr_opt = Some(addr)
            }
            let mut bytes = vec![];
            m.serialize(&mut bytes).unwrap();
            bytes
        })
        .collect::<Vec<Vec<u8>>>();
    // TODO: allow genesis modules published under different addresses. supporting this while
    // maintaining the topological order is challenging.
    session
        .publish_module_bundle(modules, addr_opt.unwrap(), &mut GasStatus::new_unmetered())
        .unwrap_or_else(|e| panic!("Failure publishing modules {:?}", e));
}