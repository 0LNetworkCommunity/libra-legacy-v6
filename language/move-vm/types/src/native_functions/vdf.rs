// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    loaded_data::runtime_types::Type,
    native_functions::{
        context::NativeContext,
        dispatch::{native_gas, NativeResult},
    },
    values::{Value},
};
use libra_types::vm_error::{StatusCode, VMStatus};
use move_core_types::gas_schedule::NativeCostIndex;
use std::collections::VecDeque;
use vm::errors::VMResult;
use vdf::{VDFParams, VDF};

/// Rust implementation of Move's `native public fun verify(challenge: vector<u8>, difficulty: u64, alleged_solution: vector<u8>): bool`
pub fn verify(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> VMResult<NativeResult> {
    if arguments.len() != 3 {
        let msg = format!(
            "wrong number of arguments for sha3_256 expected 3 found {}",
            arguments.len()
        );
        return Err(VMStatus::new(StatusCode::UNREACHABLE).with_message(msg));
    }

    let challenge = pop_arg!(arguments, Vec<u8>);
    let difficulty = pop_arg!(arguments, u64);
    let alleged_solution = pop_arg!(arguments, Vec<u8>);

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::SHA3_256,
        challenge.len(),
    );
    // let hash_vec = HashValue::from_sha3_256(hash_arg.as_slice()).to_vec();
    // let return_values = vec![Value::vector_u8(hash_vec)];
    let p = vdf::WesolowskiVDFParams(2048);
    let v = p.new();
    match v.verify(&challenge, difficulty, &alleged_solution) {
        Ok(_) => {
            let return_values = vec![Value::bool(true)];
            Ok(NativeResult::ok(cost, return_values))
        }
        Err(_) => {
            let return_values = vec![Value::bool(false)];
            Ok(NativeResult::ok(cost, return_values))
        }
    }
}