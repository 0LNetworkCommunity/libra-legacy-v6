// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

mod genesis_context;
pub mod genesis_gas_schedule;

use serde::{Deserialize, Serialize};
// use hex;
use std::env;

use crate::{genesis_context::GenesisStateView, genesis_gas_schedule::INITIAL_GAS_SCHEDULE};
use compiled_stdlib::{stdlib_modules, transaction_scripts::StdlibScript, StdLibOptions};
use libra_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    PrivateKey, Uniform,
};
use libra_types::{
    account_address,
    account_config::{
        self,
        events::{CreateAccountEvent},
    },
    chain_id::{ChainId},
    contract_event::ContractEvent,
    on_chain_config::VMPublishingOption,
    transaction::{
        authenticator::AuthenticationKey, ChangeSet, Script, Transaction, TransactionArgument,
        WriteSetPayload,
    },
};
use libra_vm::{data_cache::StateViewCache, txn_effects_to_writeset_and_events};
use move_core_types::{
    account_address::AccountAddress,
    gas_schedule::{CostTable, GasAlgebra, GasUnits},
    identifier::Identifier,
    language_storage::{ModuleId, StructTag, TypeTag},
};
use move_vm_runtime::{
    data_cache::TransactionEffects,
    logging::{LogContext, NoContextLog},
    move_vm::MoveVM,
    session::Session,
};
use move_vm_types::{
    gas_schedule::{zero_cost_schedule, CostStrategy},
    values::Value,
};
use once_cell::sync::Lazy;
use rand::prelude::*;
use transaction_builder::encode_create_designated_dealer_script;
use vm::{file_format::SignatureToken, CompiledModule};

// The seed is arbitrarily picked to produce a consistent key. XXX make this more formal?
const GENESIS_SEED: [u8; 32] = [42; 32];

const GENESIS_MODULE_NAME: &str = "Genesis";

pub static GENESIS_KEYPAIR: Lazy<(Ed25519PrivateKey, Ed25519PublicKey)> = Lazy::new(|| {
    let mut rng = StdRng::from_seed(GENESIS_SEED);
    let private_key = Ed25519PrivateKey::generate(&mut rng);
    let public_key = private_key.public_key();
    (private_key, public_key)
});

pub static ZERO_COST_SCHEDULE: Lazy<CostTable> = Lazy::new(zero_cost_schedule);

const ZERO_AUTH_KEY: [u8; 32] = [0; 32];

pub type Name = Vec<u8>;
// Defines a validator owner and maps that to an operator
pub type OperatorAssignment = (Option<Ed25519PublicKey>, Name, Script, AccountAddress, GenesisMiningProof);

// Defines a validator operator and maps that to a validator (config)
pub type OperatorRegistration = (Ed25519PublicKey, Name, Script, AccountAddress, GenesisMiningProof);

pub fn encode_genesis_transaction(
    libra_root_key: Ed25519PublicKey,
    treasury_compliance_key: Ed25519PublicKey,
    operator_assignments: &[OperatorAssignment],
    operator_registrations: &[OperatorRegistration],
    vm_publishing_option: Option<VMPublishingOption>,
    chain_id: ChainId,
) -> Transaction {
    Transaction::GenesisTransaction(WriteSetPayload::Direct(encode_genesis_change_set(
        &libra_root_key,
        &treasury_compliance_key,
        operator_assignments,
        operator_registrations,
        stdlib_modules(StdLibOptions::Compiled), // Must use compiled stdlib,
        vm_publishing_option
            .unwrap_or_else(|| VMPublishingOption::locked(StdlibScript::allowlist())),
        chain_id,
    )))
}

fn merge_txn_effects(
    mut effects_1: TransactionEffects,
    effects_2: TransactionEffects,
) -> TransactionEffects {
    effects_1.resources.extend(effects_2.resources);
    effects_1.modules.extend(effects_2.modules);
    effects_1.events.extend(effects_2.events);
    effects_1
}

pub fn encode_genesis_change_set(
    libra_root_key: &Ed25519PublicKey,
    treasury_compliance_key: &Ed25519PublicKey,
    operator_assignments: &[OperatorAssignment],
    operator_registrations: &[OperatorRegistration],
    stdlib_modules: &[CompiledModule],
    vm_publishing_option: VMPublishingOption,
    chain_id: ChainId,
) -> ChangeSet {
    // create a data view for move_vm
    let mut state_view = GenesisStateView::new();
    for module in stdlib_modules {
        let module_id = module.self_id();
        state_view.add_module(&module_id, &module);
    }
    let data_cache = StateViewCache::new(&state_view);

    let move_vm = MoveVM::new();
    let mut session = move_vm.new_session(&data_cache);
    let log_context = NoContextLog::new();

    let lbr_ty = TypeTag::Struct(StructTag {
        address: *account_config::LBR_MODULE.address(),
        module: account_config::LBR_MODULE.name().to_owned(),
        name: account_config::LBR_STRUCT_NAME.to_owned(),
        type_params: vec![],
    });


    create_and_initialize_main_accounts(
        &mut session,
        &log_context,
        &libra_root_key,
        &treasury_compliance_key,
        vm_publishing_option,
        &lbr_ty,
        chain_id,
    );
    println!("OK create_and_initialize_main_accounts =============== ");

    //////// 0L ////////
    initialize_testnet(&mut session, &log_context, true);
    println!("OK initialize_testnet =============== ");

    // generate the genesis WriteSet
    create_and_initialize_owners_operators(
        &mut session,
        &log_context,
        &operator_assignments,
        &operator_registrations,
    );

    println!("OK create_and_initialize_owners_operators =============== ");


    


    // initialize_miners(&mut session, &log_context, &operator_registrations);
    
    // println!("OK initialize_miners_alt =============== ");

    distribute_genesis_subsidy(&mut session, &log_context);


    reconfigure(&mut session, &log_context);
    
    // if [NamedChain::TESTNET, NamedChain::DEVNET, NamedChain::TESTING]
    //     .iter()
    //     .any(|test_chain_id| test_chain_id.id() == chain_id.id())
    // {
    //     create_and_initialize_testnet_minting(&mut session, &log_context, &treasury_compliance_key);
    // }
    let effects_1 = session.finish().unwrap();
    let state_view = GenesisStateView::new();
    let data_cache = StateViewCache::new(&state_view);
    let mut session = move_vm.new_session(&data_cache);
    publish_stdlib(&mut session, &log_context, stdlib_modules);
    let effects_2 = session.finish().unwrap();

    let effects = merge_txn_effects(effects_1, effects_2);

    let (write_set, events) = txn_effects_to_writeset_and_events(effects).unwrap();

    assert!(!write_set.iter().any(|(_, op)| op.is_deletion()));
    verify_genesis_write_set(&events);
    ChangeSet::new(write_set, events)
}

/// Convert the transaction arguments into Move values.
fn convert_txn_args(args: &[TransactionArgument]) -> Vec<Value> {
    args.iter()
        .map(|arg| match arg {
            TransactionArgument::U8(i) => Value::u8(*i),
            TransactionArgument::U64(i) => Value::u64(*i),
            TransactionArgument::U128(i) => Value::u128(*i),
            TransactionArgument::Address(a) => Value::address(*a),
            TransactionArgument::Bool(b) => Value::bool(*b),
            TransactionArgument::U8Vector(v) => Value::vector_u8(v.clone()),
        })
        .collect()
}

fn exec_function(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    sender: AccountAddress,
    module_name: &str,
    function_name: &str,
    ty_args: Vec<TypeTag>,
    args: Vec<Value>,
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
            sender,
            &mut CostStrategy::system(&ZERO_COST_SCHEDULE, GasUnits::new(100_000_000)),
            log_context,
        )
        .unwrap_or_else(|e| {
            panic!(
                "Error calling {}.{}: {}",
                module_name,
                function_name,
                e.into_vm_status()
            )
        })
}

fn exec_script(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    sender: AccountAddress,
    script: &Script,
) {
    session
        .execute_script(
            script.code().to_vec(),
            script.ty_args().to_vec(),
            convert_txn_args(script.args()),
            vec![sender],
            &mut CostStrategy::system(&ZERO_COST_SCHEDULE, GasUnits::new(100_000_000)),
            log_context,
        )
        .unwrap()
}

/// Create and initialize Association and Core Code accounts.
fn create_and_initialize_main_accounts(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    libra_root_key: &Ed25519PublicKey,
    _treasury_compliance_key: &Ed25519PublicKey,
    publishing_option: VMPublishingOption,
    lbr_ty: &TypeTag,
    chain_id: ChainId,
) {
    let libra_root_auth_key = AuthenticationKey::ed25519(libra_root_key);
    // let treasury_compliance_auth_key = AuthenticationKey::ed25519(treasury_compliance_key);

    let root_libra_root_address = account_config::libra_root_address();
    // let tc_account_address = account_config::treasury_compliance_account_address();

    let initial_allow_list = Value::constant_vector_generic(
        publishing_option
            .script_allow_list
            .into_iter()
            .map(|hash| Value::vector_u8(hash.to_vec().into_iter())),
        &Box::new(SignatureToken::Vector(Box::new(SignatureToken::U8))),
    )
    .unwrap();

    let genesis_gas_schedule = &INITIAL_GAS_SCHEDULE;
    let instr_gas_costs = lcs::to_bytes(&genesis_gas_schedule.instruction_table)
        .expect("Failure serializing genesis instr gas costs");
    let native_gas_costs = lcs::to_bytes(&genesis_gas_schedule.native_table)
        .expect("Failure serializing genesis native gas costs");

    exec_function(
        session,
        log_context,
        root_libra_root_address,
        GENESIS_MODULE_NAME,
        "initialize",
        vec![],
        vec![
            Value::transaction_argument_signer_reference(root_libra_root_address),
            Value::vector_u8(libra_root_auth_key.to_vec()),
            initial_allow_list,
            Value::bool(publishing_option.is_open_module),
            Value::vector_u8(instr_gas_costs),
            Value::vector_u8(native_gas_costs),
            Value::u8(chain_id.id()),
        ],
    );

    // Bump the sequence number for the Association account. If we don't do this and a
    // subsequent transaction (e.g., minting) is sent from the Assocation account, a problem
    // arises: both the genesis transaction and the subsequent transaction have sequence
    // number 0
    exec_function(
        session,
        log_context,
        root_libra_root_address,
        "LibraAccount",
        "epilogue",
        vec![lbr_ty.clone()],
        vec![
            Value::transaction_argument_signer_reference(root_libra_root_address),
            Value::u64(/* txn_sequence_number */ 0),
            Value::u64(/* txn_gas_price */ 0),
            Value::u64(/* txn_max_gas_units */ 0),
            Value::u64(/* gas_units_remaining */ 0),
        ],
    );
}

fn _create_and_initialize_testnet_minting(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    public_key: &Ed25519PublicKey,
) {
    let genesis_auth_key = AuthenticationKey::ed25519(public_key);
    let create_dd_script = encode_create_designated_dealer_script(
        account_config::lbr_type_tag(),
        0,
        account_config::testnet_dd_account_address(),
        genesis_auth_key.prefix().to_vec(),
        b"moneybags".to_vec(), // name
        true,                  // add_all_currencies
    );

    let mint_max_coin1_tmp = transaction_builder::encode_tiered_mint_script(
        account_config::lbr_type_tag(),
        0,
        account_config::testnet_dd_account_address(),
        std::u64::MAX / 2,
        3,
    );
    // Create the DD account
    exec_script(
        session,
        log_context,
        account_config::treasury_compliance_account_address(),
        &create_dd_script,
    );
    exec_function(
        session,
        log_context,
        account_config::treasury_compliance_account_address(),
        "DesignatedDealer",
        "update_tier",
        vec![account_config::lbr_type_tag()],
        vec![
            Value::transaction_argument_signer_reference(
                account_config::treasury_compliance_account_address(),
            ),
            Value::address(account_config::testnet_dd_account_address()),
            Value::u64(3),
            Value::u64(std::u64::MAX),
        ],
    );
    // mint Coin1.
    let treasury_compliance_account_address = account_config::treasury_compliance_account_address();
    exec_script(
        session,
        log_context,
        treasury_compliance_account_address,
        &mint_max_coin1_tmp,
    );

    let testnet_dd_account_address = account_config::testnet_dd_account_address();
    exec_script(
        session,
        log_context,
        testnet_dd_account_address,
        &transaction_builder::encode_rotate_authentication_key_script(genesis_auth_key.to_vec()),
    );
}

/// Creates and initializes each validator owner and validator operator. This method creates all
/// the required accounts, sets the validator operators for each validator owner, and sets the
/// validator config on-chain.
fn create_and_initialize_owners_operators(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    operator_assignments: &[OperatorAssignment],
    operator_registrations: &[OperatorRegistration],
) {
    let libra_root_address = account_config::libra_root_address();

    // Create accounts for each validator owner. The inputs for creating an account are the auth
    // key prefix and account address. Internally move then computes the auth key as auth key
    // prefix || address. Because of this, the initial auth key will be invalid as we produce the
    // account address from the name and not the public key.
    println!("0 ======== Create Owner Accounts");
    for (owner_key, owner_name, _op_assignment, _ , genesis_proof) in operator_assignments {
        let staged_owner_auth_key = libra_config::utils::default_validator_owner_auth_key_from_name(owner_name);
        let owner_address = staged_owner_auth_key.derived_address();
        let create_owner_script = transaction_builder::encode_create_validator_account_script(
            0,
            owner_address,
            staged_owner_auth_key.prefix().to_vec(),
            owner_name.clone(),
        );
        exec_script(
            session,
            log_context,
            libra_root_address,
            &create_owner_script,
        );

        // If there is a key, make it the auth key, otherwise use a zero auth key.
        let real_owner_auth_key = if let Some(owner_key) = owner_key {
            AuthenticationKey::ed25519(owner_key).to_vec()
        } else {
            ZERO_AUTH_KEY.to_vec()
        };

        exec_script(
            session,
            log_context,
            owner_address.clone(),
            &transaction_builder::encode_rotate_authentication_key_script(real_owner_auth_key),
        );

        // Submit mining proof
        let preimage = hex::decode(&genesis_proof.preimage).unwrap();
        let proof = hex::decode(&genesis_proof.proof).unwrap();
        exec_function(
            session,
            log_context,
            libra_root_address,
            "MinerState",
            "genesis_helper",
            vec![],
            vec![
                Value::transaction_argument_signer_reference(libra_root_address),
                Value::transaction_argument_signer_reference(owner_address),
                Value::vector_u8(preimage),
                Value::vector_u8(proof)
            ]
        );
    }

    println!("1 ======== Create OP Accounts");
    // Create accounts for each validator operator
    for (operator_key, operator_name, _, _, _genesis_proof) in operator_registrations {
        let operator_auth_key = AuthenticationKey::ed25519(&operator_key);
        let operator_account = account_address::from_public_key(operator_key);
        let create_operator_script =
            transaction_builder::encode_create_validator_operator_account_script(
                0,
                operator_account,
                operator_auth_key.prefix().to_vec(),
                operator_name.clone(),
            );
        exec_script(
            session,
            log_context,
            libra_root_address,
            &create_operator_script,
        );
    }

    println!("2 ======== Link owner to OP");


    // Authorize an operator for a validator/owner
    for (_owner_key, owner_name, op_assignment_script, _op_account , _genesis_proof) in operator_assignments {
        let owner_address = libra_config::utils::validator_owner_account_from_name(owner_name);

        exec_script(session, log_context, owner_address, op_assignment_script);
    }

    println!("3 ======== OP sends network info to Owner config");
    // Set the validator operator configs for each owner
    for (operator_key, _, registration, _account , _genesis_proof) in operator_registrations {
        let operator_account = account_address::from_public_key(operator_key);
        exec_script(session, log_context, operator_account, registration);
    }

    println!("4 ======== Add owner to validator set");

    // Add each validator to the validator set
    for (_owner_key, owner_name, _op_assignment, _account , _genesis_proof) in operator_assignments {
        let owner_address = libra_config::utils::validator_owner_account_from_name(owner_name);
        exec_function(
            session,
            log_context,
            libra_root_address,
            "LibraSystem",
            "add_validator",
            vec![],
            vec![
                Value::transaction_argument_signer_reference(libra_root_address),
                Value::address(owner_address),
            ],
        );
    }
}

fn remove_genesis(stdlib_modules: &[CompiledModule]) -> impl Iterator<Item = &CompiledModule> {
    stdlib_modules
        .iter()
        .filter(|module| module.self_id().name().as_str() != GENESIS_MODULE_NAME)
}

/// Publish the standard library.
fn publish_stdlib(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    stdlib: &[CompiledModule],
) {
    for module in remove_genesis(stdlib) {
        assert!(module.self_id().name().as_str() != GENESIS_MODULE_NAME);
        let mut module_vec = vec![];
        module.serialize(&mut module_vec).unwrap();
        session
            .publish_module(
                module_vec,
                *module.self_id().address(),
                &mut CostStrategy::system(&ZERO_COST_SCHEDULE, GasUnits::new(100_000_000)),
                log_context,
            )
            .unwrap_or_else(|e| {
                panic!("Failure publishing module {:?}, {:?}", module.self_id(), e)
            });
    }
}

/// Trigger a reconfiguration. This emits an event that will be passed along to the storage layer.
fn reconfigure(session: &mut Session<StateViewCache>, log_context: &impl LogContext) {
    exec_function(
        session,
        log_context,
        account_config::libra_root_address(),
        "LibraConfig",
        "emit_genesis_reconfiguration_event",
        vec![],
        vec![],
    );
}

/// Verify the consistency of the genesis `WriteSet`
fn verify_genesis_write_set(events: &[ContractEvent]) {
    // (1) first event is account creation event for LibraRoot
    let create_libra_root_event = &events[0];
    assert_eq!(
        *create_libra_root_event.key(),
        CreateAccountEvent::event_key(),
    );

    // (2) second event is account creation event for TreasuryCompliance
    let create_treasury_compliance_event = &events[1];
    assert_eq!(
        *create_treasury_compliance_event.key(),
        CreateAccountEvent::event_key(),
    );

    // (3) The first non-account creation event should be the new epoch event
    // let new_epoch_events: Vec<&ContractEvent> = events
    //     .iter()
    //     .filter(|e| e.key() == &NewEpochEvent::event_key())
    //     .collect();
    // assert!(
    //     new_epoch_events.len() == 1,
    //     "There should only be one NewEpochEvent"
    // );
    // (4) This should be the first new_epoch_event
    // assert_eq!(new_epoch_events[0].sequence_number(), 0,);
}

/// Generate an artificial genesis `ChangeSet` for testing
pub fn generate_genesis_change_set_for_testing(stdlib_options: StdLibOptions) -> ChangeSet {
    generate_test_genesis(
        &stdlib_modules(stdlib_options),
        VMPublishingOption::open(),
        None,
    )
    .0
}

pub fn test_genesis_transaction() -> Transaction {
    let changeset = test_genesis_change_set_and_validators(None).0;
    Transaction::GenesisTransaction(WriteSetPayload::Direct(changeset))
}

pub fn test_genesis_change_set_and_validators(count: Option<usize>) -> (ChangeSet, Vec<Validator>) {
    generate_test_genesis(
        &stdlib_modules(StdLibOptions::Compiled),
        VMPublishingOption::locked(StdlibScript::allowlist()),
        count,
    )
}

pub struct Validator {
    pub index: usize,
    pub key: Ed25519PrivateKey,
    pub name: Vec<u8>,
    pub operator_address: AccountAddress,
    pub owner_address: AccountAddress,
}

impl Validator {
    pub fn new_set(count: Option<usize>) -> Vec<Validator> {
        let mut rng: rand::rngs::StdRng = rand::SeedableRng::from_seed([1u8; 32]);
        (0..count.unwrap_or(4))
            .map(|idx| Validator::gen(idx, &mut rng))
            .collect()
    }

    fn gen(index: usize, rng: &mut rand::rngs::StdRng) -> Self {
        let name = index.to_string().as_bytes().to_vec();
        let key = Ed25519PrivateKey::generate(rng);
        let operator_address = account_address::from_public_key(&key.public_key());
        let owner_address = libra_config::utils::validator_owner_account_from_name(&name);

        Self {
            index,
            key,
            name,
            operator_address,
            owner_address,
        }
    }

    fn operator_assignment(&self) -> OperatorAssignment {
        let set_operator_script = transaction_builder::encode_set_validator_operator_script(
            self.name.clone(),
            self.operator_address,
        );

        (
            Some(self.key.public_key()),
            self.name.clone(),
            set_operator_script,
            self.operator_address,
            GenesisMiningProof::default() //NOTE: For testing only
        )
    }

    fn operator_registration(&self) -> OperatorRegistration {
        let script = transaction_builder::encode_register_validator_config_script(
            self.owner_address,
            self.key.public_key().to_bytes().to_vec(),
            lcs::to_bytes(&[0u8; 0]).unwrap(),
            lcs::to_bytes(&[0u8; 0]).unwrap(),
        );
        (
            self.key.public_key(),
            self.name.clone(),
            script,
            self.owner_address, 
            GenesisMiningProof::default() //NOTE: For testing only
        )
    }
}

pub fn generate_test_genesis(
    stdlib_modules: &[CompiledModule],
    vm_publishing_option: VMPublishingOption,
    count: Option<usize>,
) -> (ChangeSet, Vec<Validator>) {
    let validators = Validator::new_set(count);
    let genesis = encode_genesis_change_set(
        &GENESIS_KEYPAIR.1,
        &GENESIS_KEYPAIR.1,
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


// fn initialize_miners(
//     session: &mut Session<StateViewCache>,
//     log_context: &impl LogContext,
//     operator_regs: &[OperatorRegistration]
// ) {
//     // Genesis will abort if mining can't be confirmed.
//     let libra_root_address = account_config::libra_root_address();
//     for (_oper_key, _, _, _oper_account, mining_proof) in operator_regs {
//         // let operator_address = account_address::from_public_key(owner_key);
//         let preimage = hex::decode(&mining_proof.preimage).unwrap();
//         let proof = hex::decode(&mining_proof.proof).unwrap();

//         exec_function(
//             session,
//             log_context,
//             libra_root_address,
//             "MinerState",
//             "genesis_helper",
//             vec![],
//             vec![
//                 Value::transaction_argument_signer_reference(libra_root_address),
//                 Value::transaction_argument_signer_reference(*account),
//                 Value::vector_u8(preimage),
//                 Value::vector_u8(proof)]);
//     }

// }

/// Genesis subsidy to miners
fn distribute_genesis_subsidy(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
) { 
    let libra_root_address = account_config::libra_root_address();

    exec_function(
        session,
        log_context,
        libra_root_address,
        "Subsidy",
        "genesis",
        vec![],
        vec![
            Value::transaction_argument_signer_reference(libra_root_address)
        ]
    )
}

// 0L Change: Necessary for genesis transaction.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct GenesisMiningProof {
    pub preimage: String,
    pub proof: String,
}

impl Default for GenesisMiningProof {
    fn default() -> GenesisMiningProof {
        let node_env = match env::var("NODE_ENV") {
            Ok(val) => val,
            _ => "test".to_string() // default to "test" if not set
        };

        // These use "alice" fixtures from ../fixtures and used elsewhere in the project, in both easy(stage) and hard(Prod) mode.
        //TODO: These fixtures should be moved to /fixtures/miner_fixtures.rs

        let easy_preimage = "f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

        let easy_proof = "0000b20d390731ea0f4405e112809c18d7959a2421a54f77039c13dfd26d3170766ec4d969fd0b70c5f9c674c591a70974d2ce1198c03bedcd905442bc1177d9740c2097cff7c8081e46da4c1e4241201ce44dc99c446b03afec3d238c5263ac453fe36210664e39c4268a07d283db83a22b708fc9224408c5081f92ad13facd154145bbc514170c7dbe549b8f823a2c520f576dedf509f6ddfdd71550e988ad3af3df5be3c8524468b81dc886b7a91af98dce36eb2e07805e23adb843535dc8f88016e898d87f1d7dce9735ccb49398b083aefa3f19c1df4b0e85996bd22a1ba0a7d31dacae958828e808695e715d661b03e7347fef5367d55298b29cb94214b8ffffbf8e84a14e83de7697db052c5dddd3563084eb89fd35b39509f757e5f4f8151fee794773f053f9352a8aa63842509c5dfae4e82dc8e6f80840e63db891b16438f4e64f6743be1f94ea5bca0662340f3d2199ccc5150a8fc2bf9d910b54c73cd1321cb706e6c854132c0b1523bc4e630344f43f035f3b41eee17a7bce271234d3802a46781869dcb6f7a7056b52222ec383a4fda755b10eb8eb95b36189a3b7eb3fc2f35070bb625138e0ce6a169243339e136dfade1d4205151ac5a7a2b8f1ae2e4207a760470c353cecc205a05773eb85499f29c61e558fcdd0f0a6db828d506d7e2acb022899803156135bde344fea9734d9d295fbc4aa43864dab6a938300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001".to_owned();

        //NOTE: this is same as easy_preimage
        // let hard_preimage = easy_preimage.to_owned();
        let hard_preimage = "f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c009f240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

        let hard_proof =  "001f82a9582dfc54369c4ceb21062151b8f9e493dec76112b5ead760dc18f6e91fe202722f607f3f71ea4cee29ed39a50f28ece9fb502dbf022bff67427bb42a57a6d6ab2d4072da8f0e6f2d540289bd563a0130aff9cae95719df71847dea56f3c541d022d00bfbbf046c65fd810ff9cf5ffd3a6a1b492ccdc3de7889bd16058e6dbcc67e4900ba9d884dd00342591d41ce0e1a4d60999c867799468423183c76c795b5d3ea5be253eb65a8f4016790aa8299f4dd40d116982d76d5eb54c263a13b58bf5ddc297fa2ec4d9a4464a05bed4408548f64d465fc9bdc9891b0f8ef62c08aefd24fe76d956a8e3ba1dd5ebacb3808c257bc36a5f8632c444af8193363fff0087ae2e864d653df2dcf69fd6fd253ee07904adac1dc2d5418066be127ad186f5622a7ca15fe3471f282f43a201b8addd2d951afce908d9fcf3b5ca9ee09c6cf3e6784b9b186f020b6083af1968bd95ff49694ee07c6dca6e7a84b4eb3a7e6a9447dbc8bd2d2f5a123283322e3b4a8c31200bc61fdf0c4fe392119de819f158d8bef561807c55933259fdefa24810e92116aa054ca6392a70e00d60fb63ecbcfe80750d62f344fc1773aa76248d2c3907aa9b1b582d788327cf118f9e7ccc8bae2da547654fa67acafbd2479ba2ab932f299ce35cd3db99ba4d5ea4e6d29568e2121023ec685255996fe76599f6e1d2fe2be0ad02b0182b8b6a410cdde9bd700572851f862be5e9fa8469a3ca4a8770a8da9efdb36f51e110979c074189bedd9f79e67fd81e9626ceac2f0b181f98a39080b1921bea0e09be513227b85422bf51319d3bdf658b5eb395d32e09d23c6bfab5a44523529d03c73b2bf806d7923fcc8d76101d90844527d3a7697559c3e9e49fb1b13fa5471e30a3e9c06018c14dc89ea22769fcaa2d707fd1e9d022cadb115c02f0e03cffe2c8165061f3fc49f83adc04bc462c5b156f0b35a17fa0ca9a84bafe42bda92c7f6dea57f03a67b60e14a2b9c28ca30199305e6c8e6192adcb5e8957314ab71c50772655a33801bf25c2406f65016a2695e59f824173272611637fa3ec4fae6f1b91a439681bf2ec2a3ffc2493891497c5f7db03d3f6350f9d3b59bacb0332061ec918c78125777074d9b02c54fccbb6d5d4fb3c355b57d6fac89d3aeb9ef88d4b568d30795c15233db9cf2bcd5eb967c7b35690f75cb74484e34a1ff0e2eec44a0d971573964f9c3376b3cf52deaed62c3c4b1166e496bfa8ac7c150fc7009800773de60ffa93950c6759558a18f00795b68f901336dfdecce1c53a1f0f277b1dd3e5176047505c18e5da93e2714749eceaffd80b2f574e4715a24f331d3d128f13f547b26114c24d5862480a6fe63b3c7becdb85326a91fcad24ab093f53766c387aa66c0235244299d4fb7ed131d216972300c0090a107de40ae4dde86b50d360b5f581f76d2f53d93".to_owned();

        if node_env == "prod"  {
            return GenesisMiningProof {
                preimage: hard_preimage,
                proof: hard_proof,

            }
        } else {
            return GenesisMiningProof {
                preimage: easy_preimage,
                proof: easy_proof,
            }
        }

    }
}

// 0L Changes

fn initialize_testnet(session: &mut Session<StateViewCache>, log_context: &impl LogContext, _is_testnet: bool) {
    let root_libra_root_address = account_config::libra_root_address();

    exec_function(
        session,
        log_context,
        root_libra_root_address,
        "Testnet",
        "initialize",
        vec![],
        vec![Value::transaction_argument_signer_reference(root_libra_root_address)]);
}
