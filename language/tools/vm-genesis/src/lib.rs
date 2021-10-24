// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

mod genesis_context;

use anyhow::Error;
use serde::{Deserialize, Serialize};
use std::env;

use crate::genesis_context::GenesisStateView;
use diem_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    PrivateKey, Uniform,
};
use diem_framework_releases::{
    current_module_blobs, legacy::transaction_scripts::LegacyStdlibScript,
};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::{
    account_config::{
        self,
        events::{CreateAccountEvent},
    },
    chain_id::ChainId,
    contract_event::ContractEvent,
    on_chain_config::{VMPublishingOption, DIEM_MAX_KNOWN_VERSION},
    transaction::{
        authenticator::AuthenticationKey, ChangeSet, ScriptFunction, Transaction, WriteSetPayload,
    },
};
use diem_vm::{convert_changeset_and_events, data_cache::StateViewCache};
use move_binary_format::CompiledModule;
use move_bytecode_utils::Modules;
use move_core_types::{
    account_address::AccountAddress,
    identifier::Identifier,
    language_storage::{ModuleId, StructTag, TypeTag},
    value::{serialize_values, MoveValue},
};
use move_vm_runtime::{move_vm::MoveVM, session::Session};
use move_vm_types::gas_schedule::{GasStatus, INITIAL_GAS_SCHEDULE};
use once_cell::sync::Lazy;
use rand::prelude::*;
use transaction_builder::encode_create_designated_dealer_script_function;

//////// 0L ////////
use ol_types::account::ValConfigs;

// The seed is arbitrarily picked to produce a consistent key. XXX make this more formal?
const GENESIS_SEED: [u8; 32] = [42; 32];

const GENESIS_MODULE_NAME: &str = "Genesis";

pub static GENESIS_KEYPAIR: Lazy<(Ed25519PrivateKey, Ed25519PublicKey)> = Lazy::new(|| {
    let mut rng = StdRng::from_seed(GENESIS_SEED);
    let private_key = Ed25519PrivateKey::generate(&mut rng);
    let public_key = private_key.public_key();
    (private_key, public_key)
});

pub fn encode_genesis_transaction(
    diem_root_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    treasury_compliance_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    validators: &[Validator],
    stdlib_module_bytes: &[Vec<u8>],
    vm_publishing_option: Option<VMPublishingOption>,
    chain_id: ChainId,
) -> Transaction {
    Transaction::GenesisTransaction(WriteSetPayload::Direct(encode_genesis_change_set(
        diem_root_key,
        treasury_compliance_key,
        validators,
        stdlib_module_bytes,
        //////// 0L ////////
        vm_publishing_option.unwrap_or_else(|| VMPublishingOption::open()), // :)
        chain_id,
    )))
}

pub fn encode_genesis_change_set(
    diem_root_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    treasury_compliance_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    validators: &[Validator],
    stdlib_module_bytes: &[Vec<u8>],
    vm_publishing_option: VMPublishingOption,
    chain_id: ChainId,
) -> ChangeSet {
    let mut stdlib_modules = Vec::new();
    // create a data view for move_vm
    let mut state_view = GenesisStateView::new();
    for module_bytes in stdlib_module_bytes {
        let module = CompiledModule::deserialize(module_bytes).unwrap();
        state_view.add_module(&module.self_id(), &module_bytes);
        stdlib_modules.push(module)
    }
    let data_cache = StateViewCache::new(&state_view);

    let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
    let mut session = move_vm.new_session(&data_cache);

    //////// 0L ////////
    let xdx_ty = TypeTag::Struct(StructTag {
        address: *account_config::GAS_MODULE.address(),
        module: account_config::GAS_MODULE.name().to_owned(),
        name: account_config::GAS_IDENTIFIER.to_owned(),
        type_params: vec![],
    });

    create_and_initialize_main_accounts(
        &mut session,
        diem_root_key,
        treasury_compliance_key,
        vm_publishing_option,
        &xdx_ty,
        chain_id,
    );
    //////// 0L ////////
    println!("OK create_and_initialize_main_accounts =============== ");

    let genesis_env = get_env();
    println!("Initializing with env: {}", genesis_env);
    if genesis_env != "prod" {
        initialize_testnet(&mut session);
    }
    //////// 0L end ////////

    // generate the genesis WriteSet
    create_and_initialize_owners_operators(&mut session, validators);

    //////// 0L ////////
    println!("OK create_and_initialize_owners_operators =============== ");

    distribute_genesis_subsidy(&mut session);
    println!("OK Genesis subsidy =============== ");

    // 0L todo diem-1.4.1
    // fund_operators(&mut session, &operator_assignments);
    //////// 0L end ////////
    
    reconfigure(&mut session);

    let (mut changeset1, mut events1) = session.finish().unwrap();

    let state_view = GenesisStateView::new();
    let data_cache = StateViewCache::new(&state_view);
    let mut session = move_vm.new_session(&data_cache);
    publish_stdlib(&mut session, Modules::new(stdlib_modules.iter()));
    let (changeset2, events2) = session.finish().unwrap();

    changeset1.squash(changeset2).unwrap();
    events1.extend(events2);

    let (write_set, events) = convert_changeset_and_events(changeset1, events1).unwrap();

    assert!(!write_set.iter().any(|(_, op)| op.is_deletion()));
    verify_genesis_write_set(&events);
    ChangeSet::new(write_set, events)
}

// 0L todo diem-1.4.1: Double check 0L patch for this fn.
// Reason, the diem `fn encode_genesis_change_set` which we copy and modify to
// create this fn, changed significantly.
//////// 0L ////////
pub fn encode_recovery_genesis_changeset(
    val_assignments: &[ValRecover],
    operator_registrations: &[OperRecover],
    val_set: &[AccountAddress],
    // stdlib_modules: &[Vec<u8>],
    // vm_publishing_option: VMPublishingOption,
    chain: u8,
) -> Result<ChangeSet, Error> {
    let mut stdlib_modules = Vec::new();
    // create a data view for move_vm
    let mut state_view = GenesisStateView::new();
    for module_bytes in current_module_blobs() {
        let module = CompiledModule::deserialize(module_bytes).unwrap();
        state_view.add_module(&module.self_id(), &module_bytes);
        stdlib_modules.push(module)
    }
    let data_cache = StateViewCache::new(&state_view);

    let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
    let mut session = move_vm.new_session(&data_cache);

    //////// 0L ////////
    let xdx_ty = TypeTag::Struct(StructTag {
        address: *account_config::GAS_MODULE.address(),
        module: account_config::GAS_MODULE.name().to_owned(),
        name: account_config::GAS_IDENTIFIER.to_owned(),
        type_params: vec![],
    });

    create_and_initialize_main_accounts(
        &mut session,
        None,
        None,
        VMPublishingOption::open(),
        &xdx_ty,
        ChainId::new(chain),
    );
    //////// 0L ////////
    println!("OK create_and_initialize_main_accounts =============== ");

    let genesis_env = get_env();
    println!("Initializing with env: {}", genesis_env);
    if genesis_env != "prod" {
        initialize_testnet(&mut session);
    }
    //////// 0L end ////////

    // generate the genesis WriteSet
    recovery_owners_operators(
        &mut session, val_assignments, operator_registrations, val_set
    );

    //////// 0L ////////
    println!("OK recovery_owners_operators =============== ");

    distribute_genesis_subsidy(&mut session);
    println!("OK Genesis subsidy =============== ");

    // 0L todo diem-1.4.1
    // fund_operators(&mut session, &operator_assignments);
    //////// 0L end ////////
    
    reconfigure(&mut session);

    let (mut changeset1, mut events1) = session.finish().unwrap();

    let state_view = GenesisStateView::new();
    let data_cache = StateViewCache::new(&state_view);
    let mut session = move_vm.new_session(&data_cache);
    publish_stdlib(&mut session, Modules::new(stdlib_modules.iter()));
    let (changeset2, events2) = session.finish().unwrap();

    changeset1.squash(changeset2).unwrap();
    events1.extend(events2);

    let (write_set, events) = convert_changeset_and_events(changeset1, events1).unwrap();

    assert!(!write_set.iter().any(|(_, op)| op.is_deletion()));
    verify_genesis_write_set(&events);
    Ok(ChangeSet::new(write_set, events))
}

fn exec_function(
    session: &mut Session<StateViewCache>,

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

fn exec_script_function(
    session: &mut Session<StateViewCache>,

    sender: AccountAddress,
    script_function: &ScriptFunction,
) {
    session
        .execute_script_function(
            script_function.module(),
            script_function.function(),
            script_function.ty_args().to_vec(),
            script_function.args().to_vec(),
            vec![sender],
            &mut GasStatus::new_unmetered(),
        )
        .unwrap()
}

//////// 0L ////////
/// Create and initialize Association and Core Code accounts.
fn create_and_initialize_main_accounts(
    session: &mut Session<StateViewCache>,

    diem_root_key: Option<&Ed25519PublicKey>,
    _treasury_compliance_key: Option<&Ed25519PublicKey>,
    publishing_option: VMPublishingOption,
    xdx_ty: &TypeTag,
    chain_id: ChainId,
) {
    let diem_root_auth_key: AuthenticationKey;
    if diem_root_key.is_some() {
        diem_root_auth_key = AuthenticationKey::ed25519(&diem_root_key.unwrap());
    } else {
        diem_root_auth_key = AuthenticationKey::new([
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0,
        ]);
    }
    // let treasury_compliance_auth_key = AuthenticationKey::ed25519(treasury_compliance_key);

    let root_diem_root_address = account_config::diem_root_address();
    // let tc_account_address = account_config::treasury_compliance_account_address();

    let initial_allow_list = MoveValue::Vector(
        publishing_option
            .script_allow_list
            .into_iter()
            .map(|hash| MoveValue::vector_u8(hash.to_vec().into_iter().collect()))
            .collect(),
    );

    let genesis_gas_schedule = &INITIAL_GAS_SCHEDULE;
    let instr_gas_costs = bcs::to_bytes(&genesis_gas_schedule.instruction_table)
        .expect("Failure serializing genesis instr gas costs");
    let native_gas_costs = bcs::to_bytes(&genesis_gas_schedule.native_table)
        .expect("Failure serializing genesis native gas costs");

    exec_function(
        session,
        GENESIS_MODULE_NAME,
        "initialize",
        vec![],
        serialize_values(&vec![
            MoveValue::Signer(root_diem_root_address),
            // MoveValue::Signer(tc_account_address),
            MoveValue::vector_u8(diem_root_auth_key.to_vec()),
            // MoveValue::vector_u8(treasury_compliance_auth_key.to_vec()),
            initial_allow_list,
            MoveValue::Bool(publishing_option.is_open_module),
            MoveValue::vector_u8(instr_gas_costs),
            MoveValue::vector_u8(native_gas_costs),
            MoveValue::U8(chain_id.id()),
            MoveValue::U64(DIEM_MAX_KNOWN_VERSION.major),
        ]),
    );

    // Bump the sequence number for the Association account. If we don't do this and a
    // subsequent transaction (e.g., minting) is sent from the Assocation account, a problem
    // arises: both the genesis transaction and the subsequent transaction have sequence
    // number 0
    exec_function(
        session,
        "DiemAccount",
        "epilogue",
        vec![xdx_ty.clone()],
        serialize_values(&vec![
            MoveValue::Signer(root_diem_root_address),
            MoveValue::U64(/* txn_sequence_number */ 0),
            MoveValue::U64(/* txn_gas_price */ 0),
            MoveValue::U64(/* txn_max_gas_units */ 0),
            MoveValue::U64(/* gas_units_remaining */ 0),
        ]),
    );
}

fn _create_and_initialize_testnet_minting( //////// 0L ////////
    session: &mut Session<StateViewCache>,

    public_key: &Ed25519PublicKey,
) {
    let genesis_auth_key = AuthenticationKey::ed25519(public_key);
    let create_dd_script = encode_create_designated_dealer_script_function(
        account_config::xus_tag(),
        0,
        account_config::testnet_dd_account_address(),
        genesis_auth_key.prefix().to_vec(),
        b"moneybags".to_vec(), // name
        true,                  // add_all_currencies
    )
    .into_script_function();

    let mint_max_xus = transaction_builder::encode_tiered_mint_script_function(
        account_config::xus_tag(),
        0,
        account_config::testnet_dd_account_address(),
        std::u64::MAX / 2,
        3,
    )
    .into_script_function();

    // Create the DD account
    exec_script_function(
        session,
        account_config::treasury_compliance_account_address(),
        &create_dd_script,
    );

    // mint XUS.
    let treasury_compliance_account_address = account_config::treasury_compliance_account_address();
    exec_script_function(session, treasury_compliance_account_address, &mint_max_xus);

    let testnet_dd_account_address = account_config::testnet_dd_account_address();
    exec_script_function(
        session,
        testnet_dd_account_address,
        &transaction_builder::encode_rotate_authentication_key_script_function(
            genesis_auth_key.to_vec(),
        )
        .into_script_function(),
    );
}

//////// 0L ////////
/// Creates and initializes each validator owner and validator operator. This method creates all
/// the required accounts, sets the validator operators for each validator owner, and sets the
/// validator config on-chain.
fn create_and_initialize_owners_operators(
    session: &mut Session<StateViewCache>,
    validators: &[Validator],
) {
    let diem_root_address = account_config::diem_root_address();

    println!("0 ======== Create Owner Accounts");

    let mut owners = vec![];
    let mut owner_names = vec![];
    let mut owner_auth_keys = vec![];
    let mut operators = vec![];
    let mut operator_names = vec![];
    let mut operator_auth_keys = vec![];
    let mut consensus_pubkeys = vec![];
    let mut validator_network_addresses = vec![];
    let mut full_node_network_addresses = vec![];

    for v in validators {
        owners.push(MoveValue::Signer(v.address));
        owner_names.push(MoveValue::vector_u8(v.name.clone()));
        owner_auth_keys.push(MoveValue::vector_u8(v.auth_key.to_vec()));
        consensus_pubkeys.push(MoveValue::vector_u8(v.consensus_pubkey.clone()));
        operators.push(MoveValue::Signer(v.operator_address));
        operator_names.push(MoveValue::vector_u8(v.operator_name.clone()));
        operator_auth_keys.push(MoveValue::vector_u8(v.operator_auth_key.to_vec()));
        validator_network_addresses.push(MoveValue::vector_u8(v.network_address.clone()));
        full_node_network_addresses.push(MoveValue::vector_u8(v.full_node_network_address.clone()));
    }
    exec_function(
        session,
        GENESIS_MODULE_NAME,
        "create_initialize_owners_operators",
        vec![],
        serialize_values(&vec![
            MoveValue::Signer(diem_root_address),
            MoveValue::Vector(owners),
            MoveValue::Vector(owner_names),
            MoveValue::Vector(owner_auth_keys),
            MoveValue::Vector(consensus_pubkeys),
            MoveValue::Vector(operators),
            MoveValue::Vector(operator_names),
            MoveValue::Vector(operator_auth_keys),
            MoveValue::Vector(validator_network_addresses),
            MoveValue::Vector(full_node_network_addresses),
        ]),
    );
}

//////// 0L ///////
// Validator/owner state to recover in genesis recovery mode
#[derive(Debug, Clone, PartialEq, PartialOrd)]
pub struct ValRecover {
    ///
    pub val_account: AccountAddress,
    ///
    pub operator_delegated_account: AccountAddress,
    ///
    pub val_auth_key: AuthenticationKey,
}

/// Operator state to recover in genesis recovery mode
#[derive(Debug, Clone, PartialEq)]
pub struct OperRecover {
    ///
    pub operator_account: AccountAddress,
    ///
    pub operator_auth_key: AuthenticationKey,
    ///
    pub validator_to_represent: AccountAddress,
    ///
    pub operator_consensus_pubkey: Vec<u8>,
    ///
    pub validator_network_addresses: Vec<u8>,
    ///
    pub fullnode_network_addresses: Vec<u8>,
}

//////// 0L ////////
/// TODO: recovery mode is WIP.
/// 
/// Creates and initializes each validator owner and validator operator. This method creates all
/// the required accounts, sets the validator operators for each validator owner, and sets the
/// validator config on-chain.
fn recovery_owners_operators(
    session: &mut Session<StateViewCache>,
    // log_context: &impl LogContext,
    val_assignments: &[ValRecover],
    operator_registrations: &[OperRecover],
    val_set: &[AccountAddress],
) {
    let diem_root_address = account_config::diem_root_address();

    // Create accounts for each validator owner. The inputs for creating an account are the auth
    // key prefix and account address. Internally move then computes the auth key as auth key
    // prefix || address. Because of this, the initial auth key will be invalid as we produce the
    // account address from the name and not the public key.
    println!("0 ======== Create Owner Accounts");
    for i in val_assignments {
        println!("account: {:?}", i.val_account);
        // TODO: why does this need to be derived from human name?
        // let owner_address = staged_owner_auth_key.derived_address();
        let create_owner_script =
            transaction_builder::encode_create_validator_account_script_function(
                0,
                i.val_account,
                i.val_auth_key.prefix().to_vec(),
                i.val_account.to_vec(),
            )
            .into_script_function();
        exec_script_function(
            session,
            // log_context,
            diem_root_address,
            &create_owner_script,
        );

        println!("======== recover miner state");
        // TODO: Where's this function recover_miner_state. Lost from v4 to v5?
        // exec_function(
        //     session,
        //     // log_context,
        //     "TowerState",
        //     "recover_miner_state", 
        //     vec![],
        //     serialize_values(&vec![
        //         MoveValue::Signer(diem_root_address),
        //         MoveValue::Signer(i.val_account),
        //     ]),
        // );

        exec_function(
            session,
            // log_context,
            "ValidatorUniverse",
            "genesis_helper",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(i.val_account),
            ]),
        );
    }

    println!("1 ======== Create OP Accounts");
    // Create accounts for each validator operator
    for i in operator_registrations {
        let create_operator_script =
            transaction_builder::encode_create_validator_operator_account_script_function(
                0,
                i.operator_account,
                i.operator_auth_key.prefix().to_vec(),
                i.operator_account.to_vec(),
            )
            .into_script_function();
        exec_script_function(
            session,
            // log_context,
            diem_root_address,
            &create_operator_script,
        );
    }

    println!("2 ======== Link owner to OP");
    // Authorize an operator for a validator/owner
    for i in val_assignments {
        let create_operator_script =
            transaction_builder::encode_set_validator_operator_with_nonce_admin_script_function(
                0,
                i.operator_delegated_account.to_vec(),
                i.operator_delegated_account,
            )
            .into_script_function();
        exec_script_function(
            session,
            // log_context,
            i.val_account, //TODO: check the signer is correct
            &create_operator_script,
        );
    }

    println!("3 ======== OP sends network info to Owner config");
    // Set the validator operator configs for each owner
    for i in operator_registrations {
        let create_operator_script =
            transaction_builder::encode_register_validator_config_script_function(
                i.validator_to_represent,
                i.operator_consensus_pubkey.clone(),
                i.validator_network_addresses.clone(),
                i.fullnode_network_addresses.clone(),
            )
            .into_script_function();
        exec_script_function(
            session,
            // log_context,
            i.operator_account,
            &create_operator_script,
        );
    }

    println!("4 ======== Add owner to validator set");
    // Add each validator to the validator set
    for i in val_set {
        // let staged_owner_auth_key = AuthenticationKey::ed25519(owner_key.as_ref().unwrap());
        // let owner_address = staged_owner_auth_key.derived_address();
        // // let owner_address = diem_config::utils::validator_owner_account_from_name(owner_name);
        exec_function(
            session,
            // log_context,
            "DiemSystem",
            "add_validator",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Address(*i),
            ]),
        );
    }
}

/// Publish the standard library.
fn publish_stdlib(session: &mut Session<StateViewCache>, stdlib: Modules) {
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

/// Trigger a reconfiguration. This emits an event that will be passed along to the storage layer.
fn reconfigure(session: &mut Session<StateViewCache>) {
    exec_function(
        session,
        "DiemConfig",
        "emit_genesis_reconfiguration_event",
        vec![],
        vec![],
    );
}

/// Verify the consistency of the genesis `WriteSet`
fn verify_genesis_write_set(events: &[ContractEvent]) {
    // (1) first event is account creation event for DiemRoot
    let create_diem_root_event = &events[0];
    assert_eq!(
        *create_diem_root_event.key(),
        CreateAccountEvent::event_key(),
    );

    // (2) second event is account creation event for TreasuryCompliance
    let create_treasury_compliance_event = &events[1];
    assert_eq!(
        *create_treasury_compliance_event.key(),
        CreateAccountEvent::event_key(),
    );

    //////// 0L ////////
    // // (3) The first non-account creation event should be the new epoch event
    // let new_epoch_events: Vec<&ContractEvent> = events
    //     .iter()
    //     .filter(|e| e.key() == &NewEpochEvent::event_key())
    //     .collect();
    // assert!(
    //     new_epoch_events.len() == 1,
    //     "There should only be one NewEpochEvent"
    // );
    // // (4) This should be the first new_epoch_event
    // assert_eq!(new_epoch_events[0].sequence_number(), 0,);
}

/// An enum specifying whether the compiled stdlib/scripts should be used or freshly built versions
/// should be used.
#[derive(Debug, Eq, PartialEq)]
pub enum GenesisOptions {
    Compiled,
    Fresh,
}

/// Generate an artificial genesis `ChangeSet` for testing
pub fn generate_genesis_change_set_for_testing(genesis_options: GenesisOptions) -> ChangeSet {
    let modules = match genesis_options {
        GenesisOptions::Compiled => diem_framework_releases::current_module_blobs(),
        GenesisOptions::Fresh => diem_framework::module_blobs(),
    };

    generate_test_genesis(modules, VMPublishingOption::open(), None).0
}

pub fn test_genesis_transaction() -> Transaction {
    let changeset = test_genesis_change_set_and_validators(None).0;
    Transaction::GenesisTransaction(WriteSetPayload::Direct(changeset))
}

pub fn test_genesis_change_set_and_validators(
    count: Option<usize>,
) -> (ChangeSet, Vec<TestValidator>) {
    generate_test_genesis(
        &current_module_blobs(),
        VMPublishingOption::locked(LegacyStdlibScript::allowlist()),
        count,
    )
}

#[derive(Debug, Clone)]
pub struct Validator {
    /// The Diem account address of the validator
    pub address: AccountAddress,
    /// UTF8-encoded name for the validator
    pub name: Vec<u8>,
    /// Authentication key for the validator
    pub auth_key: AuthenticationKey,
    /// Ed25519 public key used to sign consensus messages
    pub consensus_pubkey: Vec<u8>,
    /// The Diem account address of the validator's operator (same as `address` if the validator is
    /// its own operator)
    pub operator_address: AccountAddress,
    /// UTF8-encoded name of the operator
    pub operator_name: Vec<u8>,
    /// Authentication key for the operator
    pub operator_auth_key: AuthenticationKey,
    /// `NetworkAddress` for the validator
    pub network_address: Vec<u8>,
    /// `NetworkAddress` for the validator's full node
    pub full_node_network_address: Vec<u8>,
}

pub struct TestValidator {
    pub key: Ed25519PrivateKey,
    pub data: Validator,
}

impl TestValidator {
    pub fn new_test_set(count: Option<usize>) -> Vec<TestValidator> {
        let mut rng: rand::rngs::StdRng = rand::SeedableRng::from_seed([1u8; 32]);
        (0..count.unwrap_or(10))
            .map(|idx| TestValidator::gen(idx, &mut rng))
            .collect()
    }

    fn gen(index: usize, rng: &mut rand::rngs::StdRng) -> TestValidator {
        let name = index.to_string().as_bytes().to_vec();
        let address = diem_config::utils::validator_owner_account_from_name(&name);
        let key = Ed25519PrivateKey::generate(rng);
        let auth_key = AuthenticationKey::ed25519(&key.public_key());
        let consensus_pubkey = key.public_key().to_bytes().to_vec();
        let operator_auth_key = auth_key;
        let operator_address = operator_auth_key.derived_address();
        let operator_name = name.clone();
        let network_address = [0u8; 0].to_vec();
        let full_node_network_address = [0u8; 0].to_vec();

        let data = Validator {
            address,
            name,
            auth_key,
            consensus_pubkey,
            operator_address,
            operator_name,
            operator_auth_key,
            network_address,
            full_node_network_address,
        };
        Self { key, data }
    }
}

pub fn generate_test_genesis(
    stdlib_modules: &[Vec<u8>],
    vm_publishing_option: VMPublishingOption,
    count: Option<usize>,
) -> (ChangeSet, Vec<TestValidator>) {
    let test_validators = TestValidator::new_test_set(count);
    let validators_: Vec<Validator> = test_validators.iter().map(|t| t.data.clone()).collect();
    let validators = &validators_;

    let genesis = encode_genesis_change_set(
        Some(&GENESIS_KEYPAIR.1), //////// 0L ////////
        Some(&GENESIS_KEYPAIR.1), //////// 0L ////////
        validators,
        stdlib_modules,
        vm_publishing_option,
        ChainId::test(),
    );
    (genesis, test_validators)
}

//////// 0L ////////
/// Genesis subsidy to genesis set
fn distribute_genesis_subsidy(
    session: &mut Session<StateViewCache>,
    // log_context: &impl LogContext,
) {
    let diem_root_address = account_config::diem_root_address();

    exec_function(
        session,
        // log_context,
        "Subsidy",
        "genesis",
        vec![],
        serialize_values(&vec![MoveValue::Signer(diem_root_address)]),
    )
}

// 0L todo diem-1.4.1
// //////// 0L /////////
// fn fund_operators(
//   session: &mut Session<StateViewCache>,
//   // log_context: &impl LogContext,
//   operator_assignments: &[OperatorAssignment],
// ) {
//     println!("4 ======== Add owner to validator set");
//     // Add each validator to the validator set
//     for (owner_key, _owner_name, _op_assignment, _genesis_proof, operator_account) in
//         operator_assignments
//     {
//         let diem_root_address = account_config::diem_root_address();

//         let staged_owner_auth_key = AuthenticationKey::ed25519(owner_key.as_ref().unwrap());
//         let owner_address = staged_owner_auth_key.derived_address();
//         // give the operator balance to be able to send txs for owner, e.g. tower-builder
//         exec_function(
//             session,
//             // log_context,
//             "DiemAccount",
//             "genesis_fund_operator",
//             vec![],
//             serialize_values(&vec![
//                 MoveValue::Signer(diem_root_address),
//                 MoveValue::Signer(owner_address),
//                 MoveValue::Address(*operator_account),
//             ]),
//         );
//     }
// }

//////// 0L ////////
fn get_env() -> String {
    match env::var("NODE_ENV") {
        Ok(val) => val,
        _ => "test".to_string(), // default to "test" if not set
    }
}

//////// 0L ////////
// 0L Change: Necessary for genesis transaction.
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct GenesisMiningProof {
    pub preimage: String,
    pub proof: String,
    pub profile: Option<ValConfigs>,
}

//////// 0L ////////
impl Default for GenesisMiningProof {
    fn default() -> GenesisMiningProof {
        // These use "alice" fixtures from ../fixtures and used elsewhere in the project, in both easy(stage) and hard(Prod) mode.

        let easy_preimage = "87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e65746400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e".to_owned();

        let easy_proof = "002c4dc1276a8a58ea88fc9974c847f14866420cbc62e5712baf1ae26b6c38a393c4acba3f72d8653e4b2566c84369601bdd1de5249233f60391913b59f0b7f797f66897de17fb44a6024570d2f60e6c5c08e3156d559fbd901fad0f1343e0109a9083e661e5d7f8c1cc62e815afeee31d04af8b8f31c39a5f4636af2b468bf59a0010f48d79e7475be62e7007d71b7355944f8164e761cd9aca671a4066114e1382fbe98834fe32cf494d01f31d1b98e3ef6bffa543928810535a063c7bbf491c472263a44d9269b1cbcb0aa351f8bd894e278b5d5667cc3f26a35b9f8fd985e4424bedbb3b77bdcc678ccbb9ed92c1730dcdd3a89c1a8766cbefa75d6eeb7e5921000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001".to_owned();

        //NOTE: this is same as easy_preimage
        // let hard_preimage = easy_preimage.to_owned();
        let hard_preimage = "87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e6574404b4c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e".to_owned();

        let hard_proof =  "001725678f78425dac39e394fc07698dd8fc891dfba0822cecc5d21434dacde903f508c1e12844eb4b97a598653cc6d03524335edf51b43f090199288488b537fd977cc5f53069f609a2f758f121e887f28f0fc1150aa5649255f8b7caea9edf6228640358d1a4fe43ddb6ad6ce1c3a6a28166e2f0b7e7310e80bfbb1db85e096000065a89b7f44ebc495d70db6034fd529a80e0b5bb74ace62cffb89f4e16e54f93e4a0063ca3651dd8486b466607973a51aacb0c66213e64e0b7bf291c64d81ed4a517a0abe58da4ae46f6191c808d9ba7c636cee404ed02248794db3fab6e5e4ab517f6f3fa12f39fb88fb5a143b5d9c16a31e3c3e173deb11494f792b52a67a70034a065c665b1ef05921a6a8ac4946365d61b2b4d5b86a607ba73659863d774c3fc7c2372f5b6c8b5ae068d4e20aac5e42b501bf441569d377f70e8f87db8a6f9b1eadb813880dbeb89872121849df312383f4d8007747ae76e66e5a13d9457af173ebb0c5eb9c39ee1ac5cef94aa75e1d5286349c88051c36507960de1f37377ffddc80a66578b437ac2a6d04fc7a595075b978bd844919d03ffe9db5b6440b753273c498aa2a139de42188d278d1ce1e3ddfdd99a97a64907e1cdf30d1c55dfc7262cd3175eb1f268ee2a91576fcd6bd644031413f55e42c510d08a81e747de36c0a6c9019d219571ea6851f43a551d6012a5317cc52992a72c270c1570419665".to_owned();

        if get_env() == "test" {
            return GenesisMiningProof {
                preimage: easy_preimage,
                proof: easy_proof,
                profile: None,
            };
        } else {
            return GenesisMiningProof {
                preimage: hard_preimage,
                proof: hard_proof,
                profile: None,
            };
        }
    }
}

//////// 0L ////////
fn initialize_testnet(
    session: &mut Session<StateViewCache>/*, log_context: &impl LogContext*/
) {
    let diem_root_address = account_config::diem_root_address();
    let mut module_name = "Testnet";
    if get_env() == "stage" {
        module_name = "StagingNet";
    };
    exec_function(
        session,
        // log_context,
        module_name,
        "initialize",
        vec![],
        serialize_values(&vec![MoveValue::Signer(diem_root_address)]),
    );
}
