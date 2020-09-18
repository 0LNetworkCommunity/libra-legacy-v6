// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

mod genesis_context;
mod genesis_gas_schedule;


use crate::{
    genesis_context::{GenesisContext, GenesisStateView},
    genesis_gas_schedule::INITIAL_GAS_SCHEDULE,
};
use bytecode_verifier::VerifiedModule;
use libra_config::config::{NodeConfig, GenesisMiningProof, HANDSHAKE_VERSION};
use libra_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    PrivateKey, Uniform, ValidCryptoMaterial,
};
use libra_network_address::RawNetworkAddress;
use libra_types::{
    account_config,
    contract_event::ContractEvent,
    on_chain_config::{config_address, new_epoch_event_key, VMPublishingOption},
    transaction::{authenticator::AuthenticationKey, ChangeSet, Script, Transaction},
};
use libra_vm::data_cache::StateViewCache;
use move_core_types::language_storage::{StructTag, TypeTag};
use move_vm_types::{data_store::DataStore, loaded_data::types::FatStructType, values::Value};
use once_cell::sync::Lazy;
use rand::prelude::*;
use std::{collections::btree_map::BTreeMap, convert::TryFrom};
use stdlib::{stdlib_modules, transaction_scripts::StdlibScript, StdLibOptions};
use vm::access::ModuleAccess;
use std::env;

// The seed is arbitrarily picked to produce a consistent key. XXX make this more formal?
const GENESIS_SEED: [u8; 32] = [42; 32];

const GENESIS_MODULE_NAME: &str = "GenesisOL";

pub static GENESIS_KEYPAIR: Lazy<(Ed25519PrivateKey, Ed25519PublicKey)> = Lazy::new(|| {
    let mut rng = StdRng::from_seed(GENESIS_SEED);
    let private_key = Ed25519PrivateKey::generate(&mut rng);
    let public_key = private_key.public_key();
    (private_key, public_key)
});

pub type ValidatorRegistration = (Ed25519PublicKey, Script, GenesisMiningProof); // 0L Change.


pub fn encode_genesis_transaction_with_validator(
    validators: &[ValidatorRegistration],
    vm_publishing_option: Option<VMPublishingOption>,
) -> Transaction {
    encode_genesis_transaction(
        validators,
        stdlib_modules(StdLibOptions::Staged), // Must use staged stdlib
        vm_publishing_option
            .unwrap_or_else(|| VMPublishingOption::Locked(StdlibScript::whitelist())),
    )
}

pub fn encode_genesis_change_set(
    validators: &[ValidatorRegistration],
    stdlib_modules: &[VerifiedModule],
    vm_publishing_option: VMPublishingOption,
) -> (ChangeSet, BTreeMap<Vec<u8>, FatStructType>) {
    // create a data view for move_vm
    let mut state_view = GenesisStateView::new();
    for module in stdlib_modules {
        let module_id = module.self_id();
        state_view.add_module(&module_id, &module);
    }
    let data_cache = StateViewCache::new(&state_view);

    let mut genesis_context = GenesisContext::new(&data_cache, stdlib_modules);


    // 0L Load the default currency. LBR_MODULE maps to GAS.
    let lbr_ty = TypeTag::Struct(StructTag {
        address: *account_config::LBR_MODULE.address(),
        module: account_config::LBR_MODULE.name().to_owned(),
        name: account_config::LBR_STRUCT_NAME.to_owned(),
        type_params: vec![],
    });

    // generate the genesis WriteSet
    let node_env = match env::var("NODE_ENV") {
        Ok(val) => val,
        _ => "test".to_string()
    };

    // Initializing testnet only when env is set to test
    if node_env != "prod" {
        initialize_testnet(&mut genesis_context);
    } else {
        println!("INITIALIZING WITH PROD CONSTANTS")
    }
    create_and_initialize_main_accounts(&mut genesis_context, &lbr_ty);
    initialize_validators(&mut genesis_context, &validators, &lbr_ty);
    initialize_miners(&mut genesis_context, &validators);
    distribute_genesis_subsidy(&mut genesis_context);

    setup_vm_config(&mut genesis_context, vm_publishing_option);
    reconfigure(&mut genesis_context);
    let mut interpreter_context = genesis_context.into_data_store();
    publish_stdlib(&mut interpreter_context, stdlib_modules);
    verify_genesis_write_set(interpreter_context.events());
    (
        ChangeSet::new(
            interpreter_context
                .make_write_set()
                .expect("Genesis WriteSet failure"),
            interpreter_context.events().to_vec(),
        ),
        interpreter_context.get_type_map(),
    )
}

pub fn encode_genesis_transaction(
    validators: &[ValidatorRegistration],
    stdlib_modules: &[VerifiedModule],
    vm_publishing_option: VMPublishingOption,
) -> Transaction {
    Transaction::WaypointWriteSet(
        encode_genesis_change_set(
            validators,
            stdlib_modules,
            vm_publishing_option,
        )
        .0,
    )
}

/// Create an initialize Association, Transaction Fee and Core Code accounts.
fn create_and_initialize_main_accounts(
    context: &mut GenesisContext,
    lbr_ty: &TypeTag,
) {
    let vm_address = account_config::vm_address();
    let fee_account_address = account_config::transaction_fee_address();
    let burn_account_address = account_config::burn_account_address();

    context.exec(
        GENESIS_MODULE_NAME,
        "initialize",
        vec![],
        vec![
            Value::transaction_argument_signer_reference(vm_address),
            Value::transaction_argument_signer_reference(config_address()),
            Value::transaction_argument_signer_reference(fee_account_address),
            Value::transaction_argument_signer_reference(burn_account_address),
        ],
    );

    // Bump the sequence number for the Association account. If we don't do this and a
    // subsequent transaction (e.g., minting) is sent from the Assocation account, a problem
    // arises: both the genesis transaction and the subsequent transaction have sequence
    // number 0
    context.exec(
        "LibraAccount",
        "epilogue",
        vec![lbr_ty.clone()],
        vec![
            Value::transaction_argument_signer_reference(vm_address),
            Value::u64(/* txn_sequence_number */ 0),
            Value::u64(/* txn_gas_price */ 0),
            Value::u64(/* txn_max_gas_units */ 0),
            Value::u64(/* gas_units_remaining */ 0),
        ],
    );
}

/// Initialize each validator.
fn initialize_validators(
    context: &mut GenesisContext,
    validators: &[ValidatorRegistration],
    lbr_ty: &TypeTag,
) {
    for (account_key, registration, _ ) in validators {
        let auth_key = AuthenticationKey::ed25519(&account_key);
        let account = auth_key.derived_address();

        // Create a validator account
        context.exec(
            "LibraAccount",
            "create_validator_account",
            vec![lbr_ty.clone()],
            vec![
                Value::transaction_argument_signer_reference(account_config::vm_address()),
                Value::address(account),
                Value::vector_u8(auth_key.prefix().to_vec()),
            ],
        );

        context.set_sender(account);

        //registration script that runs for each validator
        context.exec_script(registration);
    }
}

/// Initialize each validator.
fn initialize_miners(context: &mut GenesisContext, validators: &[ValidatorRegistration]) {
    // Genesis will abort if mining can't be confirmed.
    
    for (account_key, _ , mining_proof) in validators {
        let auth_key = AuthenticationKey::ed25519(&account_key);
        let account = auth_key.derived_address(); // check if we need derive a new address or use validator's account instead
        let preimage = hex::decode(&mining_proof.preimage).unwrap();
        let proof = hex::decode(&mining_proof.proof).unwrap();
        context.set_sender( account );
        context.exec(
            "MinerState",
            "genesis_helper",
            vec![],
            vec![
                Value::transaction_argument_signer_reference(account),
                Value::vector_u8(preimage), // serialize for move.
                Value::vector_u8(proof),
            ],
        );
    }

}

/// Distribute genesis subsidy to initialized validators
fn distribute_genesis_subsidy(context: &mut GenesisContext) {
    // println!("distributing genesis subsidy to validators");

    // let root_association_address = account_config::vm_address();
    context.set_sender(account_config::vm_address());
    context.exec(
        "Subsidy",
        "genesis",
        vec![],
        vec![Value::transaction_argument_signer_reference(account_config::vm_address())]);
    }

fn initialize_testnet(context: &mut GenesisContext) {
    context.exec(
        "Testnet",
        "initialize",
        vec![],
        vec![Value::transaction_argument_signer_reference(account_config::vm_address())]);
}

fn setup_vm_config(context: &mut GenesisContext, publishing_option: VMPublishingOption) {
    context.set_sender(config_address());

    let option_bytes =
        lcs::to_bytes(&publishing_option).expect("Cannot serialize publishing option");
    context.exec(
        "LibraVMConfig",
        "initialize",
        vec![],
        vec![
            Value::transaction_argument_signer_reference(config_address()),
            Value::vector_u8(option_bytes),
            Value::vector_u8(INITIAL_GAS_SCHEDULE.0.clone()),
            Value::vector_u8(INITIAL_GAS_SCHEDULE.1.clone()),
        ],
    );
}

// get all move modules escept for genesis.
//TODO: we still have the old genesis.
fn remove_genesis(stdlib_modules: &[VerifiedModule]) -> impl Iterator<Item = &VerifiedModule> {
    stdlib_modules
        .iter()
        .filter(|module| module.self_id().name().as_str() != GENESIS_MODULE_NAME)
}

/// Publish the standard library.
fn publish_stdlib(interpreter_context: &mut dyn DataStore, stdlib: &[VerifiedModule]) {
    for module in remove_genesis(stdlib) {
        assert!(module.self_id().name().as_str() != GENESIS_MODULE_NAME);
        let mut module_vec = vec![];
        module.serialize(&mut module_vec).unwrap();
        interpreter_context
            .publish_module(module.self_id(), module_vec)
            .unwrap_or_else(|_| panic!("Failure publishing module {:?}", module.self_id()));
    }
}

/// Trigger a reconfiguration. This emits an event that will be passed along to the storage layer.
fn reconfigure(context: &mut GenesisContext) {
    context.set_sender(account_config::vm_address());
    context.exec("LibraConfig", "emit_reconfiguration_event", vec![], vec![]);
}

/// Verify the consistency of the genesis `WriteSet`
fn verify_genesis_write_set(events: &[ContractEvent]) {
    // Sanity checks on emitted events:
    // (1) The genesis tx should emit 1 event: a NewEpochEvent.
    // assert_eq!(
    //     events.len(),
    //     1,
    //     "Genesis transaction should emit one event, but found {} events: {:?}",
    //     events.len(),
    //     events,
    // );

    // (2) The first event should be the new epoch event
    let new_epoch_event = &events[events.len()-1];
    assert_eq!(
        *new_epoch_event.key(),
        new_epoch_event_key(),
        "Key of emitted event {:?} does not match change event key {:?}",
        *new_epoch_event.key(),
        new_epoch_event_key(),
    );
    // (3) This should be the first new_epoch_event
    assert_eq!(
        new_epoch_event.sequence_number(),
        0,
        "Expected sequence number 0 for validator set change event but got {}",
        new_epoch_event.sequence_number()
    );
}

/// Generate an artificial genesis `ChangeSet` for testing
// 0L Follow this for e2e testing
pub fn generate_genesis_change_set_for_testing(stdlib_options: StdLibOptions) -> ChangeSet {
    let stdlib_modules = stdlib_modules(stdlib_options);
    let swarm = libra_config::generator::validator_swarm_for_testing(4);
    encode_genesis_change_set(
        &validator_registrations(&swarm.nodes).0,
        stdlib_modules,
        VMPublishingOption::Open,
    )
    .0
}

/// Generate an artificial genesis `ChangeSet` for testing
pub fn generate_genesis_type_mapping() -> BTreeMap<Vec<u8>, FatStructType> {
    let stdlib_modules = stdlib_modules(StdLibOptions::Staged);
    let swarm = libra_config::generator::validator_swarm_for_testing(4);

    encode_genesis_change_set(
        &validator_registrations(&swarm.nodes).0,
        stdlib_modules,
        VMPublishingOption::Open,
    )
    .1
}
// For testing purposes.
pub fn validator_registrations(node_configs: &[NodeConfig]) -> (Vec<ValidatorRegistration>, &[NodeConfig])  {
    let registrations = node_configs
        .iter()
        .map(|n| {
            // println!("node_configs\n{:?}", node_configs);
            let test = n.test.as_ref().unwrap();
            let account_key = test.operator_keypair.as_ref().unwrap().public_key();
            let consensus_key = test.consensus_keypair.as_ref().unwrap().public_key();
            let network = n.validator_network.as_ref().unwrap();
            let identity_key = network.identity.public_key_from_config().unwrap();

            let advertised_address = network
                .advertised_address
                .clone()
                .append_prod_protos(identity_key, HANDSHAKE_VERSION);
            let raw_advertised_address = RawNetworkAddress::try_from(&advertised_address).unwrap();

            // TODO(philiphayes): do something with n.full_node_networks instead
            // of ignoring them?

            let script = transaction_builder::encode_register_validator_script(
                consensus_key.to_bytes().to_vec(),
                identity_key.to_bytes(),
                raw_advertised_address.clone().into(),
                identity_key.to_bytes(),
                raw_advertised_address.into(),
            );
            // 0L Change. Adding node configs

            let genesis_proof = n.miner_swarm_fixture.as_ref().expect("No miner fixtures given").to_owned();

            (account_key, script, genesis_proof) // 0L Change.
        })
        .collect::<Vec<_>>();
        (registrations, node_configs)
}
