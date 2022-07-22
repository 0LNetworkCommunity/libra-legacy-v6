// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

mod genesis_context;
pub mod genesis_gas_schedule;

use anyhow::Error;
use std::{env, process::exit};

use crate::{genesis_context::GenesisStateView, genesis_gas_schedule::INITIAL_GAS_SCHEDULE};
use diem_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    PrivateKey, Uniform,
};
use diem_framework_releases::{
    current_module_blobs, legacy::transaction_scripts::LegacyStdlibScript,
};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::{
    account_address,
    account_config::{self, events::CreateAccountEvent},
    chain_id::ChainId,
    contract_event::ContractEvent,
    on_chain_config::{VMPublishingOption, DIEM_MAX_KNOWN_VERSION},
    transaction::{
        authenticator::AuthenticationKey, ChangeSet, ScriptFunction, Transaction, WriteSetPayload,
    },
};
use diem_vm::{convert_changeset_and_events, data_cache::StateViewCache};
use move_binary_format::CompiledModule;
use move_core_types::{
    account_address::AccountAddress,
    identifier::Identifier,
    language_storage::{ModuleId, StructTag, TypeTag},
    value::{serialize_values, MoveValue},
};
use move_vm_runtime::{
    logging::{LogContext, NoContextLog},
    move_vm::MoveVM,
    session::Session,
};
use move_vm_types::gas_schedule::GasStatus;
use once_cell::sync::Lazy;
use rand::prelude::*;
use transaction_builder::encode_create_designated_dealer_script_function;

//////// 0L ////////
use ol_types::{config::IS_PROD, genesis_proof::GenesisMiningProof};
use diem_global_constants::{GENESIS_VDF_SECURITY_PARAM, genesis_delay_difficulty};

// The seed is arbitrarily picked to produce a consistent key. XXX make this more formal?
const GENESIS_SEED: [u8; 32] = [42; 32];

const GENESIS_MODULE_NAME: &str = "Genesis";
const DIEM_VERSION_MODULE_NAME: &str = "DiemVersion";

pub static GENESIS_KEYPAIR: Lazy<(Ed25519PrivateKey, Ed25519PublicKey)> = Lazy::new(|| {
    let mut rng = StdRng::from_seed(GENESIS_SEED);
    let private_key = Ed25519PrivateKey::generate(&mut rng);
    let public_key = private_key.public_key();
    (private_key, public_key)
});

const ZERO_AUTH_KEY: [u8; 32] = [0; 32];

pub type Name = Vec<u8>;
//////// 0L ////////
// Defines a validator owner and maps that to an operator
pub type OperatorAssignment = (
    Option<Ed25519PublicKey>,
    Name,
    ScriptFunction,
    //////// 0L ////////
    GenesisMiningProof, //proof of work
    AccountAddress,     // operator address
);

//////// 0L ////////
// Defines a validator operator and maps that to a validator (config)
pub type OperatorRegistration = (Ed25519PublicKey, Name, ScriptFunction, AccountAddress);

pub fn encode_genesis_transaction(
    diem_root_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    treasury_compliance_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    operator_assignments: &[OperatorAssignment],
    operator_registrations: &[OperatorRegistration],
    vm_publishing_option: Option<VMPublishingOption>,
    chain_id: ChainId,
) -> Transaction {
    Transaction::GenesisTransaction(WriteSetPayload::Direct(encode_genesis_change_set(
        diem_root_key,
        treasury_compliance_key,
        operator_assignments,
        operator_registrations,
        current_module_blobs(), // Must use compiled stdlib,
        //////// 0L ////////
        vm_publishing_option.unwrap_or_else(|| VMPublishingOption::open()), // :)
        chain_id,
    )))
}

pub fn encode_genesis_change_set(
    diem_root_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    treasury_compliance_key: Option<&Ed25519PublicKey>, //////// 0L ////////
    operator_assignments: &[OperatorAssignment],
    operator_registrations: &[OperatorRegistration],
    stdlib_modules: &[Vec<u8>],
    vm_publishing_option: VMPublishingOption,
    chain_id: ChainId,
) -> ChangeSet {
    dbg!(&chain_id);

    let mut stdlib_module_tuples: Vec<(ModuleId, &Vec<u8>)> = Vec::new();
    // create a data view for move_vm
    let mut state_view = GenesisStateView::new();
    for module in stdlib_modules {
        let module_id = CompiledModule::deserialize(module).unwrap().self_id();
        state_view.add_module(&module_id, &module);
        stdlib_module_tuples.push((module_id, module));
    }
    let data_cache = StateViewCache::new(&state_view);

    let move_vm = MoveVM::new();
    let mut session = move_vm.new_session(&data_cache);
    let log_context = NoContextLog::new();

    //////// 0L ////////
    let xdx_ty = TypeTag::Struct(StructTag {
        address: *account_config::GAS_MODULE.address(),
        module: account_config::GAS_MODULE.name().to_owned(),
        name: account_config::GAS_IDENTIFIER.to_owned(),
        type_params: vec![],
    });

    if !*IS_PROD {
        initialize_testnet(&mut session, &log_context);
    }
    //////// 0L end ////////

    create_and_initialize_main_accounts(
        &mut session,
        &log_context,
        diem_root_key,
        treasury_compliance_key,
        vm_publishing_option,
        &xdx_ty,
        chain_id,
    );

    create_and_initialize_owners_operators(
        &mut session,
        &log_context,
        &operator_assignments,
        &operator_registrations,
    );

    distribute_genesis_subsidy(&mut session, &log_context);

    fund_operators(&mut session, &log_context, &operator_assignments);
    //////// 0L end ////////

    reconfigure(&mut session, &log_context);


    let (mut changeset1, mut events1) = session.finish().unwrap();

    let state_view = GenesisStateView::new();
    let data_cache = StateViewCache::new(&state_view);
    let mut session = move_vm.new_session(&data_cache);
    publish_stdlib(&mut session, &log_context, stdlib_module_tuples);
    let (changeset2, events2) = session.finish().unwrap();

    changeset1.squash(changeset2).unwrap();
    events1.extend(events2);

    let (write_set, events) = convert_changeset_and_events(changeset1, events1).unwrap();

    assert!(!write_set.iter().any(|(_, op)| op.is_deletion()));
    verify_genesis_write_set(&events);
    ChangeSet::new(write_set, events)
}

//////// 0L ////////
pub fn encode_recovery_genesis_changeset(
    val_assignments: &[ValRecover],
    operator_registrations: &[OperRecover],
    val_set: &[AccountAddress],
    // stdlib_modules: &[Vec<u8>],
    // vm_publishing_option: VMPublishingOption,
    chain: u8,
) -> Result<ChangeSet, Error> {
    let mut stdlib_module_tuples: Vec<(ModuleId, &Vec<u8>)> = Vec::new();
    // create a data view for move_vm
    let mut state_view = GenesisStateView::new();
    for module in current_module_blobs() {
        let module_id = CompiledModule::deserialize(module).unwrap().self_id();
        state_view.add_module(&module_id, &module);
        stdlib_module_tuples.push((module_id, module));
    }
    let data_cache = StateViewCache::new(&state_view);

    let move_vm = MoveVM::new();
    let mut session = move_vm.new_session(&data_cache);
    let log_context = NoContextLog::new();

    //////// 0L ////////
    let xdx_ty = TypeTag::Struct(StructTag {
        address: *account_config::GAS_MODULE.address(),
        module: account_config::GAS_MODULE.name().to_owned(),
        name: account_config::GAS_IDENTIFIER.to_owned(),
        type_params: vec![],
    });

    create_and_initialize_main_accounts(
        &mut session,
        &log_context,
        None,
        None,
        VMPublishingOption::open(),
        &xdx_ty,
        ChainId::new(chain),
    );
    //////// 0L ////////
    // println!("OK create_and_initialize_main_accounts =============== ");

    if !*IS_PROD {
        initialize_testnet(&mut session, &log_context);
    }
    //////// 0L end ////////

    // generate the genesis WriteSet
    //     // generate the genesis WriteSet
    recovery_owners_operators(
        &mut session,
        &log_context,
        &val_assignments,
        &operator_registrations,
        &val_set,
    );
    //////// 0L ////////
    // println!("OK create_and_initialize_owners_operators =============== ");

    // distribute_genesis_subsidy(&mut session, &log_context);
    // println!("OK Genesis subsidy =============== ");
    //////// 0L end ////////

    reconfigure(&mut session, &log_context);

    let (mut changeset1, mut events1) = session.finish().unwrap();

    let state_view = GenesisStateView::new();
    let data_cache = StateViewCache::new(&state_view);
    let mut session = move_vm.new_session(&data_cache);
    publish_stdlib(&mut session, &log_context, stdlib_module_tuples);
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
    log_context: &impl LogContext,
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
            log_context,
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
    log_context: &impl LogContext,
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
            log_context,
        )
        .unwrap()
}

//////// 0L ////////
/// Create and initialize Association and Core Code accounts.
fn create_and_initialize_main_accounts(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
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

    exec_function(
        session,
        log_context,
        GENESIS_MODULE_NAME,
        "initialize",
        vec![],
        serialize_values(&vec![
            MoveValue::Signer(root_diem_root_address),
            // MoveValue::Signer(tc_account_address), //////// 0L ////////
            MoveValue::vector_u8(diem_root_auth_key.to_vec()),
            //////// 0L ////////
            // MoveValue::vector_u8(treasury_compliance_auth_key.to_vec()),
            initial_allow_list,
            MoveValue::Bool(publishing_option.is_open_module),
            MoveValue::vector_u8(instr_gas_costs),
            MoveValue::vector_u8(native_gas_costs),
            MoveValue::U8(chain_id.id()),
        ]),
    );

    // Bump the Diem Framework version number
    exec_function(
        session,
        log_context,
        DIEM_VERSION_MODULE_NAME,
        "set",
        vec![],
        serialize_values(&vec![
            MoveValue::Signer(root_diem_root_address),
            MoveValue::U64(
                /* Diem Framework major version number */ DIEM_MAX_KNOWN_VERSION.major,
            ),
        ]),
    );

    // Bump the sequence number for the Association account. If we don't do this and a
    // subsequent transaction (e.g., minting) is sent from the Assocation account, a problem
    // arises: both the genesis transaction and the subsequent transaction have sequence
    // number 0
    exec_function(
        session,
        log_context,
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

fn _create_and_initialize_testnet_minting(
    //////// 0L ////////
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
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
        log_context,
        account_config::treasury_compliance_account_address(),
        &create_dd_script,
    );

    // mint XUS.
    let treasury_compliance_account_address = account_config::treasury_compliance_account_address();
    exec_script_function(
        session,
        log_context,
        treasury_compliance_account_address,
        &mint_max_xus,
    );

    let testnet_dd_account_address = account_config::testnet_dd_account_address();
    exec_script_function(
        session,
        log_context,
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
    log_context: &impl LogContext,
    operator_assignments: &[OperatorAssignment],
    operator_registrations: &[OperatorRegistration],
) {
    let diem_root_address = account_config::diem_root_address();

    // Create accounts for each validator owner. The inputs for creating an account are the auth
    // key prefix and account address. Internally move then computes the auth key as auth key
    // prefix || address. Because of this, the initial auth key will be invalid as we produce the
    // account address from the name and not the public key.
    // println!("0 ======== Create Owner Accounts");

    let all_vals: Vec<AccountAddress> = operator_registrations.iter()
    .map(|a|{
      a.3
    })
    .collect();

    for (owner_key, owner_name, _op_assignment, genesis_proof, _operator) in operator_assignments {
        // TODO: Remove. Temporary Authkey for genesis, because accounts are being created from human names.
        let staged_owner_auth_key = AuthenticationKey::ed25519(owner_key.as_ref().unwrap());
        let owner_address = staged_owner_auth_key.derived_address();
        println!("initializing owner: {}", owner_address);
        // let staged_owner_auth_key = diem_config::utils::default_validator_owner_auth_key_from_name(owner_name);
        //TODO: why does this need to be derived from human name?
        // let owner_address = staged_owner_auth_key.derived_address();
        let create_owner_script =
            transaction_builder::encode_create_validator_account_script_function(
                0,
                owner_address,
                staged_owner_auth_key.prefix().to_vec(),
                owner_name.clone(),
            )
            .into_script_function();
        exec_script_function(
            session,
            log_context,
            diem_root_address,
            &create_owner_script,
        );

        // If there is a key, make it the auth key, otherwise use a zero auth key.
        let real_owner_auth_key = if let Some(owner_key) = owner_key {
            AuthenticationKey::ed25519(owner_key).to_vec()
        } else {
            ZERO_AUTH_KEY.to_vec() // TODO: is this used for tests?
        };

        // Rotate auth key.
        exec_script_function(
            session,
            log_context,
            owner_address.clone(),
            &transaction_builder::encode_rotate_authentication_key_script_function(
                real_owner_auth_key,
            )
            .into_script_function(),
        );

        // Submit mining proof
        // Todo this should use the 0L Block type.
        let preimage = hex::decode(&genesis_proof.preimage).unwrap();
        let proof = hex::decode(&genesis_proof.proof).unwrap();
        exec_function(
            session,
            log_context,
            "TowerState",
            "genesis_helper",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(owner_address),
                MoveValue::vector_u8(preimage),
                MoveValue::vector_u8(proof),
                MoveValue::U64(genesis_delay_difficulty()), // TODO: make this part of genesis registration
                MoveValue::U64(GENESIS_VDF_SECURITY_PARAM.into()),
            ]),
        );

        //////// 0L ////////
        // submit any transactions for user e.g. Autopay
        if let Some(profile) = &genesis_proof.profile {
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
                            log_context,
                            owner_address,
                            &autopay_instruction,
                        );
                    });
                }
                None => {}
            }
        }

        exec_function(
            session,
            log_context,
            "ValidatorUniverse",
            "genesis_helper",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(owner_address),
            ]),
        );

        exec_function(
            session,
            log_context,
            "Vouch",
            "init",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(owner_address)
            ]),
        );

        let mut vals = all_vals.clone();
        vals.retain(|el|{ el != &owner_address});
        exec_function(
            session,
            log_context,
            "Vouch",
            "vm_migrate",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Address(owner_address),
                MoveValue::vector_address(vals),
            ]),
        );
    }

    // println!("1 ======== Create OP Accounts");
    // Create accounts for each validator operator
    for (operator_key, operator_name, _, _) in operator_registrations {
        let operator_auth_key = AuthenticationKey::ed25519(&operator_key);
        let operator_account = account_address::from_public_key(operator_key);
        let create_operator_script =
            transaction_builder::encode_create_validator_operator_account_script_function(
                0,
                operator_account,
                operator_auth_key.prefix().to_vec(),
                operator_name.clone(),
            )
            .into_script_function();

        exec_script_function(
            session,
            log_context,
            diem_root_address,
            &create_operator_script,
        );
    }

    // println!("2 ======== Link owner to OP");
    // Authorize an operator for a validator/owner
    for (owner_key, _owner_name, op_assignment_script, _genesis_proof, _operator) in
        operator_assignments
    {
        // let owner_address = diem_config::utils::validator_owner_account_from_name(owner_name);
        let staged_owner_auth_key = AuthenticationKey::ed25519(owner_key.as_ref().unwrap());
        let owner_address = staged_owner_auth_key.derived_address();
        exec_script_function(session, log_context, owner_address, op_assignment_script);
    }

    // println!("3 ======== OP sends network info to Owner config");
    // Set the validator operator configs for each owner
    for (operator_key, _, registration, _account) in operator_registrations {
        let operator_account = account_address::from_public_key(operator_key);
        exec_script_function(session, log_context, operator_account, registration);
    }

    // println!("4 ======== Add owner to validator set");
    // Add each validator to the validator set
    for (owner_key, _owner_name, _op_assignment, _genesis_proof, _operator_account) in
        operator_assignments
    {
        let staged_owner_auth_key = AuthenticationKey::ed25519(owner_key.as_ref().unwrap());
        let owner_address = staged_owner_auth_key.derived_address();

        exec_function(
            session,
            log_context,
            "DiemSystem",
            "add_validator",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Address(owner_address),
            ]),
        );

        // enable oracle upgrade delegation for all genesis nodes.
        exec_function(
            session,
            log_context,
            "Oracle",
            "enable_delegation",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(owner_address),
            ]),
        );
    }
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
    log_context: &impl LogContext,
    val_assignments: &[ValRecover],
    operator_registrations: &[OperRecover],
    val_set: &[AccountAddress],
) {
    let diem_root_address = account_config::diem_root_address();

    // Create accounts for each validator owner. The inputs for creating an account are the auth
    // key prefix and account address. Internally move then computes the auth key as auth key
    // prefix || address. Because of this, the initial auth key will be invalid as we produce the
    // account address from the name and not the public key.
    // println!("0 ======== Create Owner Accounts");
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
            log_context,
            diem_root_address,
            &create_owner_script,
        );

        // println!("======== recover miner state");
        // TODO: Where's this function recover_miner_state. Lost from v4 to v5?
        // exec_function(
        //     session,
        //     log_context,
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
            log_context,
            "ValidatorUniverse",
            "genesis_helper",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(i.val_account),
            ]),
        );
    }

    // println!("1 ======== Create OP Accounts");
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
            log_context,
            diem_root_address,
            &create_operator_script,
        );
    }

    // println!("2 ======== Link owner to OP");
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
            log_context,
            i.val_account, //TODO: check the signer is correct
            &create_operator_script,
        );
    }

    // println!("3 ======== OP sends network info to Owner config");
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
            log_context,
            i.operator_account,
            &create_operator_script,
        );
    }

    // println!("4 ======== Add owner to validator set");
    // Add each validator to the validator set
    for i in val_set {
        // let staged_owner_auth_key = AuthenticationKey::ed25519(owner_key.as_ref().unwrap());
        // let owner_address = staged_owner_auth_key.derived_address();
        // // let owner_address = diem_config::utils::validator_owner_account_from_name(owner_name);
        exec_function(
            session,
            log_context,
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
fn publish_stdlib(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    stdlib: Vec<(ModuleId, &Vec<u8>)>,
) {
    let genesis_removed = stdlib
        .iter()
        .filter(|(module_id, _bytes)| module_id.name().as_str() != GENESIS_MODULE_NAME);
    for (module_id, bytes) in genesis_removed {
        assert!(module_id.name().as_str() != GENESIS_MODULE_NAME);
        session
            .publish_module(
                (*bytes).clone(),
                *module_id.address(),
                &mut GasStatus::new_unmetered(),
                log_context,
            )
            .unwrap_or_else(|e| panic!("Failure publishing module {:?}, {:?}", module_id, e));
    }
}

/// Trigger a reconfiguration. This emits an event that will be passed along to the storage layer.
fn reconfigure(session: &mut Session<StateViewCache>, log_context: &impl LogContext) {
    exec_function(
        session,
        log_context,
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

pub fn test_genesis_change_set_and_validators(count: Option<usize>) -> (ChangeSet, Vec<Validator>) {
    generate_test_genesis(
        &current_module_blobs(),
        VMPublishingOption::locked(LegacyStdlibScript::allowlist()),
        count,
    )
}

pub struct Validator {
    pub index: usize,
    pub key: Ed25519PrivateKey,
    pub oper_key: Ed25519PrivateKey, //////// 0L ////////
    pub name: Vec<u8>,
    pub operator_address: AccountAddress,
    pub owner_address: AccountAddress,
}

impl Validator {
    pub fn new_set(count: Option<usize>) -> Vec<Validator> {
        let mut rng: rand::rngs::StdRng = rand::SeedableRng::from_seed([1u8; 32]);
        (0..count.unwrap_or(4)) //////// 0L ////////
            .map(|idx| Validator::gen(idx, &mut rng))
            .collect()
    }

    fn gen(index: usize, rng: &mut rand::rngs::StdRng) -> Self {
        let name = index.to_string().as_bytes().to_vec();
        let key = Ed25519PrivateKey::generate(rng);
        let oper_key = Ed25519PrivateKey::generate(rng);
        let operator_address = account_address::from_public_key(&oper_key.public_key());
        let owner_address = account_address::from_public_key(&key.public_key());

        Self {
            index,
            key,
            oper_key, //////// 0L ////////
            name,
            operator_address,
            owner_address,
        }
    }

    fn operator_assignment(&self) -> OperatorAssignment {
        let script_function = transaction_builder::encode_set_validator_operator_script_function(
            self.name.clone(),
            self.operator_address,
        )
        .into_script_function();
        (
            Some(self.key.public_key()),
            self.name.clone(),
            script_function,
            //////// 0L ////////
            GenesisMiningProof::default(), // NOTE: For testing only
            self.operator_address,
        )
    }

    fn operator_registration(&self) -> OperatorRegistration {
        let script_function =
            transaction_builder::encode_register_validator_config_script_function(
                self.owner_address,
                self.key.public_key().to_bytes().to_vec(),
                bcs::to_bytes(&[0u8; 0]).unwrap(),
                bcs::to_bytes(&[0u8; 0]).unwrap(),
            )
            .into_script_function();
        (
            self.oper_key.public_key(),
            self.name.clone(),
            script_function,
            self.operator_address, //////// 0L ////////
        )
    }
}

pub fn generate_test_genesis(
    stdlib_modules: &[Vec<u8>],
    vm_publishing_option: VMPublishingOption,
    count: Option<usize>,
) -> (ChangeSet, Vec<Validator>) {
    let validators = Validator::new_set(count);

    let genesis = encode_genesis_change_set(
        Some(&GENESIS_KEYPAIR.1), //////// 0L ////////
        Some(&GENESIS_KEYPAIR.1), //////// 0L ////////
        &validators
            .iter()
            .map(|v| v.operator_assignment())
            .collect::<Vec<_>>(),
        &validators
            .iter()
            .map(|v| v.operator_registration())
            .collect::<Vec<_>>(),
        stdlib_modules,
        vm_publishing_option,
        ChainId::test(),
    );
    (genesis, validators)
}

//////// 0L ////////
/// Genesis subsidy to genesis set
fn distribute_genesis_subsidy(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
) {
    let diem_root_address = account_config::diem_root_address();

    exec_function(
        session,
        log_context,
        "Subsidy",
        "genesis",
        vec![],
        serialize_values(&vec![MoveValue::Signer(diem_root_address)]),
    )
}

//////// 0L /////////
fn fund_operators(
  session: &mut Session<StateViewCache>,
  log_context: &impl LogContext,
  operator_assignments: &[OperatorAssignment],
) {
    // println!("4 ======== Add owner to validator set");
    // Add each validator to the validator set
    for (owner_key, _owner_name, _op_assignment, _genesis_proof, operator_account) in
        operator_assignments
    {
        let diem_root_address = account_config::diem_root_address();

        let staged_owner_auth_key = AuthenticationKey::ed25519(owner_key.as_ref().unwrap());
        let owner_address = staged_owner_auth_key.derived_address();
        // give the operator balance to be able to send txs for owner, e.g. tower-builder
        exec_function(
            session,
            log_context,
            "DiemAccount",
            "genesis_fund_operator",
            vec![],
            serialize_values(&vec![
                MoveValue::Signer(diem_root_address),
                MoveValue::Signer(owner_address),
                MoveValue::Address(*operator_account),
            ]),
        );
    }
}


//////// 0L ////////
fn initialize_testnet(session: &mut Session<StateViewCache>, log_context: &impl LogContext) {
    let diem_root_address = account_config::diem_root_address();


    let genesis_env = env::var("NODE_ENV").unwrap();
    println!("Initializing with env: {}", genesis_env);
    
    //////// 0L ////////
    let module_name = match genesis_env.as_ref() {
        "test" => "Testnet",
        "stage" => "StagingNet",
        _ => {
          println!("ERROR: env is ambiguous. Are you starting a test or staging network? Found env: {}", &genesis_env);
          exit(1);
        },
    };

    exec_function(
        session,
        log_context,
        module_name,
        "initialize",
        vec![],
        serialize_values(&vec![MoveValue::Signer(diem_root_address)]),
    );
}
