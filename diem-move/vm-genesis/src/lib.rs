// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

mod genesis_context;
use anyhow::Error;
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
        DESIGNATED_DEALER_MODULE,
    },
    chain_id::{ChainId},
    contract_event::ContractEvent,
    on_chain_config::{
        ConsensusConfigV1, OnChainConsensusConfig, ReadWriteSetAnalysis, VMPublishingOption,
        DIEM_MAX_KNOWN_VERSION,
    },
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
    language_storage::{ModuleId, TypeTag},
    value::{serialize_values, MoveValue},
};
use move_vm_runtime::{move_vm::MoveVM, session::Session};
use move_vm_types::gas_schedule::{GasStatus, INITIAL_GAS_SCHEDULE};
use once_cell::sync::Lazy;
use rand::prelude::*;
use transaction_builder::encode_create_designated_dealer_script_function;

//////// 0L ////////
use diem_global_constants::{VDF_SECURITY_PARAM, delay_difficulty};
use ol_types::genesis_proof::GenesisMiningProof;

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
    consensus_config: OnChainConsensusConfig,
    chain_id: ChainId,
    enable_parallel_execution: bool,
) -> Transaction {
    Transaction::GenesisTransaction(WriteSetPayload::Direct(encode_genesis_change_set(
        diem_root_key,
        treasury_compliance_key,
        validators,
        stdlib_module_bytes,
        //////// 0L ////////
        // vm_publishing_option
        //     .unwrap_or_else(|| VMPublishingOption::locked(LegacyStdlibScript::allowlist())),
        vm_publishing_option.unwrap_or_else(|| VMPublishingOption::open()), // :)
        consensus_config,
        chain_id,
        enable_parallel_execution,
    )))
}

pub fn encode_genesis_change_set(
    diem_root_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    treasury_compliance_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    validators: &[Validator],
    stdlib_module_bytes: &[Vec<u8>],
    vm_publishing_option: VMPublishingOption,
    consensus_config: OnChainConsensusConfig,
    chain_id: ChainId,
    enable_parallel_execution: bool,
) -> ChangeSet {
    let mut stdlib_modules = Vec::new();
    // create a data view for move_vm
    let mut state_view = GenesisStateView::new();
    let mut has_dd_module = false;
    for module_bytes in stdlib_module_bytes {
        let module = CompiledModule::deserialize(module_bytes).unwrap();
        if module.self_id() == *DESIGNATED_DEALER_MODULE {
            has_dd_module = true;
        }
        state_view.add_module(&module.self_id(), module_bytes);
        stdlib_modules.push(module)
    }
    let data_cache = StateViewCache::new(&state_view);

    let move_vm = MoveVM::new(diem_vm::natives::diem_natives()).unwrap();
    let mut session = move_vm.new_session(&data_cache);

    create_and_initialize_main_accounts(
        &mut session,
        diem_root_key,
        treasury_compliance_key,
        vm_publishing_option,
        consensus_config,
        chain_id,
    );
    //////// 0L ////////
    println!("OK create_and_initialize_main_accounts =============== ");
    let genesis_env = get_env();
    println!("Initializing with env: {}", genesis_env);
    if genesis_env != "prod" {
        initialize_testnet(&mut session);
    }
    
    // generate the genesis WriteSet
    create_and_initialize_owners_operators(&mut session, validators);

    //////// 0L ////////
    println!("OK create_and_initialize_owners_operators =============== ");
    distribute_genesis_subsidy(&mut session);
    println!("OK Genesis subsidy =============== ");
    fund_operators(&mut session, validators);
    
    reconfigure(&mut session);

    //////// 0L ////////
    // if has_dd_module
    //     && [NamedChain::TESTNET, NamedChain::DEVNET, NamedChain::TESTING]
    //         .iter()
    //         .any(|test_chain_id| test_chain_id.id() == chain_id.id())
    // {
    //     create_and_initialize_testnet_minting(&mut session, treasury_compliance_key);
    // }

    if enable_parallel_execution {
        let payload = bcs::to_bytes(&ReadWriteSetAnalysis::V1(
            read_write_set::analyze(&stdlib_modules)
                .expect("Failed to get ReadWriteSet for current Diem Framework")
                .normalize_all_scripts(diem_vm::read_write_set_analysis::add_on_functions_list())
                .trim()
                .into_inner(),
        ))
        .expect("Failed to serialize analyze result");

        exec_function(
            &mut session,
            "ParallelExecutionConfig",
            "enable_parallel_execution_with_config",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(account_config::diem_root_address()),
                MoveValue::vector_u8(payload),
            ]),
        )
    }

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
    // Perform DPN genesis verification
    if has_dd_module {
        verify_genesis_write_set(&events);
    }
    ChangeSet::new(write_set, events)
}

// 0L todo diem-1.4.1: This fn is double checked.
//                     But, still need third check/review from another person.
// Reason, the diem `fn encode_genesis_change_set` which we copy and modify to
// create this fn, changed significantly.
//////// 0L ////////
pub fn encode_recovery_genesis_changeset(
    val_assignments: &[ValRecover],
    operator_registrations: &[OperRecover],
    val_set: &[AccountAddress],
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
    create_and_initialize_main_accounts(
        &mut session,
        None,
        None,
        VMPublishingOption::open(),
        OnChainConsensusConfig::V1(ConsensusConfigV1 { two_chain: true }),
        ChainId::new(chain),
    );
    //////// 0L ////////
    println!("OK create_and_initialize_main_accounts =============== ");
    let genesis_env = get_env();
    println!("Initializing with env: {}", genesis_env);
    if genesis_env != "prod" {
        initialize_testnet(&mut session);
    }

    // generate the genesis WriteSet
    recovery_owners_operators(
        &mut session, val_assignments, operator_registrations, val_set
    );

    //////// 0L ////////
    // println!("OK recovery_owners_operators =============== ");
    // distribute_genesis_subsidy(&mut session);
    // println!("OK Genesis subsidy =============== ");

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
    session: &mut Session<StateViewCache<GenesisStateView>>,
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
    session: &mut Session<StateViewCache<GenesisStateView>>,

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

/// Create and initialize Association and Core Code accounts.
fn create_and_initialize_main_accounts(
    session: &mut Session<StateViewCache<GenesisStateView>>,
    diem_root_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    _treasury_compliance_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    publishing_option: VMPublishingOption,
    consensus_config: OnChainConsensusConfig,
    chain_id: ChainId,
) {
    //////// 0L ////////
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
    //////// 0L ////////
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

    let consensus_config_bytes =
        bcs::to_bytes(&consensus_config).expect("Failure serializing genesis consensus config");

    exec_function(
        session,
        GENESIS_MODULE_NAME,
        "initialize",
        vec![],
        serialize_values(&vec![
            MoveValue::Signer(root_diem_root_address),
            // MoveValue::Signer(tc_account_address), //////// 0L ////////
            MoveValue::vector_u8(diem_root_auth_key.to_vec()),
            // MoveValue::vector_u8(treasury_compliance_auth_key.to_vec()), //////// 0L ////////
            initial_allow_list,
            MoveValue::Bool(publishing_option.is_open_module),
            MoveValue::vector_u8(instr_gas_costs),
            MoveValue::vector_u8(native_gas_costs),
            MoveValue::U8(chain_id.id()),
            MoveValue::U64(DIEM_MAX_KNOWN_VERSION.major),
            MoveValue::vector_u8(consensus_config_bytes),
        ]),
    );
}

fn _create_and_initialize_testnet_minting( //////// 0L ////////
    session: &mut Session<StateViewCache<GenesisStateView>>,
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

/// Creates and initializes each validator owner and validator operator. This method creates all
/// the required accounts, sets the validator operators for each validator owner, and sets the
/// validator config on-chain.
fn create_and_initialize_owners_operators(
    session: &mut Session<StateViewCache<GenesisStateView>>,
    validators: &[Validator],
) {
    let diem_root_address = account_config::diem_root_address();

    println!("0 ======== Create Owner and Operator Accounts"); //////// 0L ////////

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

        //////// 0L ////////
        // Submit mining proof
        let preimage = hex::decode(&v.genesis_mining_proof.preimage).unwrap();
        let proof = hex::decode(&v.genesis_mining_proof.proof).unwrap();
        exec_function(
            session,
            "TowerState",
            "genesis_helper",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(v.address),
                MoveValue::vector_u8(preimage),
                MoveValue::vector_u8(proof),
                MoveValue::U64(delay_difficulty()), // TODO: make this part of genesis registration
                MoveValue::U64(VDF_SECURITY_PARAM.into()),                
            ]),
        );

        //////// 0L ////////
        // submit any transactions for user e.g. Autopay
        if let Some(profile) = &v.genesis_mining_proof.profile {
            match &profile.autopay_instructions {
                Some(list) => {
                    list.into_iter().for_each(|ins| {
                        let autopay_instruction =
                            transaction_builder::encode_autopay_create_instruction_script_function(
                                ins.uid.unwrap(),
                                ins.type_move.unwrap(),
                                ins.destination,
                                ins.duration_epochs.unwrap(),
                                ins.value_move.unwrap(),
                            )
                            .into_script_function();
                        exec_script_function(
                            session,
                            v.address,
                            &autopay_instruction,
                        );
                    });
                }
                None => {}
            }
        }

        //////// 0L ////////
        exec_function(
            session,
            "ValidatorUniverse",
            "genesis_helper",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(v.address),
            ]),
        );

        //////// 0L ////////
        // enable oracle upgrade delegation for all genesis nodes.
        exec_function(
            session,
            "Oracle",
            "enable_delegation",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(v.address),
            ]),
        );        
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

//////// 0L ///////
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
    session: &mut Session<StateViewCache<GenesisStateView>>,
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
fn publish_stdlib(session: &mut Session<StateViewCache<GenesisStateView>>, stdlib: Modules) {
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
fn reconfigure(session: &mut Session<StateViewCache<GenesisStateView>>) {
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
    Experimental,
}

/// Generate an artificial genesis `ChangeSet` for testing
pub fn generate_genesis_change_set_for_testing(genesis_options: GenesisOptions) -> ChangeSet {
    let modules = match genesis_options {
        GenesisOptions::Compiled => diem_framework_releases::current_module_blobs().to_vec(),
        GenesisOptions::Fresh => diem_framework::module_blobs(),
        GenesisOptions::Experimental => diem_framework::experimental_module_blobs(),
    };

    generate_test_genesis(&modules, VMPublishingOption::open(), None, false).0
}

pub fn test_genesis_transaction() -> Transaction {
    let changeset = test_genesis_change_set_and_validators(None).0;
    Transaction::GenesisTransaction(WriteSetPayload::Direct(changeset))
}

pub fn test_genesis_change_set_and_validators(
    count: Option<usize>,
) -> (ChangeSet, Vec<TestValidator>) {
    generate_test_genesis(
        current_module_blobs(),
        VMPublishingOption::locked(LegacyStdlibScript::allowlist()),
        count,
        false,
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
    //////// 0L ////////
    pub genesis_mining_proof: GenesisMiningProof, // proof of work    
}

pub struct TestValidator {
    pub key: Ed25519PrivateKey,
    pub data: Validator,
}

impl TestValidator {
    pub fn new_test_set(count: Option<usize>) -> Vec<TestValidator> {
        let mut rng: rand::rngs::StdRng = rand::SeedableRng::from_seed([1u8; 32]);
        (0..count.unwrap_or(4)) //////// 0L ////////
            .map(|idx| TestValidator::gen(idx, &mut rng))
            .collect()
    }

    fn gen(index: usize, rng: &mut rand::rngs::StdRng) -> TestValidator {
        let name = index.to_string().as_bytes().to_vec();
        // let address = diem_config::utils::validator_owner_account_from_name(&name); /////// 0L /////////
        let key = Ed25519PrivateKey::generate(rng);
        let auth_key = AuthenticationKey::ed25519(&key.public_key());
        let consensus_pubkey = key.public_key().to_bytes().to_vec();
        // let operator_auth_key = auth_key; /////// 0L /////////
        // let operator_address = operator_auth_key.derived_address(); /////// 0L /////////
        let operator_name = name.clone();
        let network_address = [0u8; 0].to_vec();
        let full_node_network_address = [0u8; 0].to_vec();
        /////// 0L /////////
        let oper_key = Ed25519PrivateKey::generate(rng);
        let operator_auth_key = AuthenticationKey::ed25519(&oper_key.public_key());
        let operator_address = 
            diem_types::account_address::from_public_key(&oper_key.public_key());
        let address = diem_types::account_address::from_public_key(&key.public_key());

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
            genesis_mining_proof: GenesisMiningProof::default(), //////// 0L ////////
        };
        Self { key, data }
    }
}

pub fn generate_test_genesis(
    stdlib_modules: &[Vec<u8>],
    vm_publishing_option: VMPublishingOption,
    count: Option<usize>,
    enable_parallel_execution: bool,
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
        OnChainConsensusConfig::V1(ConsensusConfigV1 { two_chain: true }),
        ChainId::test(),
        enable_parallel_execution,
    );
    (genesis, test_validators)
}

//////// 0L ////////
/// Genesis subsidy to genesis set
fn distribute_genesis_subsidy(
    session: &mut Session<StateViewCache<GenesisStateView>>,
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

// 0L todo diem-1.4.1 - updated patch, needs review
//////// 0L /////////
fn fund_operators(
  session: &mut Session<StateViewCache<GenesisStateView>>,
  validators: &[Validator],
) {
    println!("======== Fund operators");

    for v in validators {
        let diem_root_address = account_config::diem_root_address();
        // give the operator balance to be able to send txs for owner, e.g. tower-builder
        exec_function(
            session,
            // log_context,
            "DiemAccount",
            "genesis_fund_operator",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(v.address),
                MoveValue::Address(v.operator_address),
            ]),
        );
    }

    // Old (diem 1.3.0 patch) - to remove after review
    //
    // // Add each validator to the validator set
    // for (owner_key, _owner_name, _op_assignment, _genesis_proof, operator_account) in
    //     operator_assignments
    // {
    //     let diem_root_address = account_config::diem_root_address();

    //     // give the operator balance to be able to send txs for owner, e.g. tower-builder
    //     exec_function(
    //         session,
    //         // log_context,
    //         "DiemAccount",
    //         "genesis_fund_operator",
    //         vec![],
    //         serialize_values(&vec![
    //             MoveValue::Signer(diem_root_address),
    //             MoveValue::Signer(owner_address),
    //             MoveValue::Address(*operator_account),
    //         ]),
    //     );
    // }
}

//////// 0L ////////
fn get_env() -> String {
    match env::var("NODE_ENV") {
        Ok(val) => val,
        _ => "test".to_string(), // default to "test" if not set
    }
}

//////// 0L ////////
fn initialize_testnet(
    session: &mut Session<StateViewCache<GenesisStateView>>
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