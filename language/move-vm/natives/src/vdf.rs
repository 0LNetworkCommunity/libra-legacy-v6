// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0
use crate::counters::{
    MOVE_VM_NATIVE_VERIFY_VDF_LATENCY, MOVE_VM_NATIVE_VERIFY_VDF_PROOF_COUNT,
    MOVE_VM_NATIVE_VERIFY_VDF_PROOF_ERROR_COUNT,
};
use diem_types::{transaction::authenticator::AuthenticationKey, vm_status::StatusCode};
use move_binary_format::errors::{PartialVMError, PartialVMResult};
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::{Reference, Value},
};
use smallvec::smallvec;
use std::collections::VecDeque;
use std::convert::TryFrom;
use vdf::{VDFParams, VDF};

/// Rust implementation of Move's `native public fun verify(challenge: vector<u8>, difficulty: u64, alleged_solution: vector<u8>): bool`
pub fn verify(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    // temporary logging.
    // let start_time = Instant::now();
    let metric_timer = MOVE_VM_NATIVE_VERIFY_VDF_LATENCY.start_timer();

    if arguments.len() != 4 {
        let msg = format!(
            "wrong number of arguments for vdf_verify expected 4 found {}",
            arguments.len()
        );
        MOVE_VM_NATIVE_VERIFY_VDF_PROOF_ERROR_COUNT.inc();
        return Err(PartialVMError::new(StatusCode::UNREACHABLE).with_message(msg));
    }

    MOVE_VM_NATIVE_VERIFY_VDF_PROOF_COUNT.inc();

    // pop the arguments (reverse order).
    let security = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<u64>()?;

    let difficulty = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<u64>()?;

    let solution = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<Vec<u8>>()?;

    let challenge = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<Vec<u8>>()?;

    // refuse to try anthing with a security parameter above 2048 for DOS risk.
    if security > 2048 {
        MOVE_VM_NATIVE_VERIFY_VDF_PROOF_ERROR_COUNT.inc();
        return Err(PartialVMError::new(StatusCode::UNREACHABLE)
            .with_message("VDF security parameter above threshold".to_string()));
    }

    // TODO change the `cost_index` when we have our own cost table.
    let cost = native_gas(context.cost_table(), NativeCostIndex::VDF_VERIFY, 1);

    let v = vdf::PietrzakVDFParams(security as u16).new();
    let result = v.verify(&challenge, difficulty, &solution);

    let return_values = smallvec![Value::bool(result.is_ok())];

    // temporary logging
    // let latency = start_time.elapsed();
    metric_timer.observe_duration();
    // dbg!("vdf verification latency", &latency);

    Ok(NativeResult::ok(cost, return_values))
}

// Extracts the first 32 bits of the vdf challenge which is the auth_key
// Auth Keys can be turned into an AccountAddress type, to be serialized to a move address type.
pub fn extract_address_from_challenge(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    let cost = native_gas(context.cost_table(), NativeCostIndex::VDF_PARSE, 1);

    let challenge_vec = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<Vec<u8>>()?;

    // default empty vec will fail with error that no authentication key found.
    let auth_key_vec = challenge_vec.get(..32).unwrap_or_default();
    match AuthenticationKey::try_from(auth_key_vec) {
        Ok(auth_key) => {
            let address = auth_key.derived_address();
            let return_values = smallvec![
                Value::address(address),
                Value::vector_u8(auth_key_vec[..16].to_owned())
            ];
            Ok(NativeResult::ok(cost, return_values))
        }
        Err(_) => Ok(NativeResult::err(cost, StatusCode::VDF_AUTHKEY_PARSE as u64)),
    }
}
