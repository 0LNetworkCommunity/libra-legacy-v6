//! ol-genesis

use serde::{Deserialize, Serialize};
use std::{env, path::PathBuf};

use crate::{genesis_context::GenesisStateView, genesis_gas_schedule::INITIAL_GAS_SCHEDULE};
use compiled_stdlib::{stdlib_modules, transaction_scripts::StdlibScript, StdLibOptions};
use libra_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    PrivateKey, Uniform,
};
use libra_types::{account_address, account_config::{
        self,
        events::{CreateAccountEvent},
    }, chain_id::{ChainId}, contract_event::ContractEvent, on_chain_config::VMPublishingOption, transaction::{
        authenticator::AuthenticationKey, ChangeSet, Script, Transaction, TransactionArgument,
        WriteSetPayload,
    },
    // write_set::{WriteOp, WriteSetMut}
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


/// TODO: Duplicated with lib.rs
pub static ZERO_COST_SCHEDULE: Lazy<CostTable> = Lazy::new(zero_cost_schedule);


/// Validator/owner state to recover in genesis recovery mode
pub struct ValRecover {
  val_account: AccountAddress,
  operator_delegated_account: AccountAddress,
  val_auth_key: AuthenticationKey,
}

/// Operator state to recover in genesis recovery mode
pub struct OperRecover {
  operator_account: AccountAddress,
  operator_auth_key: AuthenticationKey,
  validator_to_represent: AccountAddress,
  operator_consensus_pubkey: Vec<u8>,
  validator_network_addresses: Vec<u8>,
  fullnode_network_addresses: Vec<u8>,
  }

//////// 0L ////////
/// Restores  owner and operator state to a genesis, in a recovery or fork scenario. No need to bootstrap all the state.
fn recovery_owners_operators(
    session: &mut Session<StateViewCache>,
    log_context: &impl LogContext,
    val_assignments: &[ValRecover],
    operator_registrations: &[OperRecover],
) {
    let libra_root_address = account_config::libra_root_address();

    // Create accounts for each validator owner. The inputs for creating an account are the auth
    // key prefix and account address. Internally move then computes the auth key as auth key
    // prefix || address. Because of this, the initial auth key will be invalid as we produce the
    // account address from the name and not the public key.
    println!("0 ======== Create Owner Accounts");
    for i in val_assignments {

        dbg!(i.val_account);
        
        let create_owner_script = transaction_builder::encode_create_validator_account_script(
            0,
            i.val_account,
            i.val_auth_key.prefix().to_vec(),
            i.val_account.to_vec(),
        );
        exec_script(
            session,
            log_context,
            libra_root_address,
            &create_owner_script,
        );

        // TODO: Restore Mining 

        // TODO: Restore ValidatorUniverse

        // TODO: Restore FullnodeState
  
    }

    println!("1 ======== Create OP Accounts");
    // Create accounts for each validator operator
    for i in operator_registrations {

        let create_operator_script =
            transaction_builder::encode_create_validator_operator_account_script(
                0,
                i.operator_account,
                i.operator_auth_key.prefix().to_vec(),
                i.operator_account.to_vec(),
            );
        exec_script(
            session,
            log_context,
            libra_root_address,
            &create_operator_script,
        );
    }

    println!("2 ======== Link owner to OP");


    let mut n = 0u64;
    // Owner/Validator is authorizing an Operator. This is sent by Owner. Operators need to have registered before this step.
    for i in val_assignments {
        let script = transaction_builder::encode_set_validator_operator_with_nonce_admin_script(
          n,
          i.operator_delegated_account.to_vec(),
          i.operator_delegated_account,
        );

      
      session
        .execute_script(
            script.code().to_vec(),
            script.ty_args().to_vec(),
            convert_txn_args(script.args()),
            vec![libra_root_address, i.val_account],
            &mut CostStrategy::system(&ZERO_COST_SCHEDULE, GasUnits::new(100_000_000)),
            log_context,
        )
        .unwrap();

        n = n+1;
    }

    println!("3 ======== OP sends network info to Owner config");
    // Set the validator operator configs for each owner. The Validator/owner needs to have linked to the Operator before this step.
    for i in operator_registrations {
        
      // Operator is signing this
        let register_val_script = transaction_builder::encode_register_validator_config_script(
          i.validator_to_represent,
          i.operator_consensus_pubkey.clone(),
          i.validator_network_addresses.clone(),
          i.fullnode_network_addresses.clone(),
        );

      session
        .execute_script(
            register_val_script.code().to_vec(),
            register_val_script.ty_args().to_vec(),
            convert_txn_args(register_val_script.args()),
            vec![i.operator_account],
            &mut CostStrategy::system(&ZERO_COST_SCHEDULE, GasUnits::new(100_000_000)),
            log_context,
        )
        .unwrap()
    }

    println!("4 ======== Add owner to validator set");

    // Add each validator to the validator set. The Validators configs need be valid before this step runs.
    for i in val_assignments {

        exec_function(
            session,
            log_context,
            libra_root_address,
            "LibraSystem",
            "add_validator",
            vec![],
            vec![
                Value::transaction_argument_signer_reference(libra_root_address),
                Value::address(i.val_account),
            ],
        );
    }
}

// TODO: duplicated with lib.rs
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

// TODO: duplicated with lib.rs
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

// TODO: duplicated with lib.rs

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
            //////// 0L ////////
            TransactionArgument::AddressVector(v) => Value::vector_address(v.clone())
        })
        .collect()
}
