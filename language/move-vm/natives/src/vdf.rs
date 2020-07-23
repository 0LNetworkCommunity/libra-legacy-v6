// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0
use vdf::{VDFParams, VDF};

use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::{Reference, Value},
};

use libra_types::vm_error::{StatusCode, VMStatus};
use std::collections::VecDeque;
use vm::errors::VMResult;

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

    let alleged_solution = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<Vec<u8>>()?;
    let difficulty = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<u64>()?;
    let challenge = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<Vec<u8>>()?;

    // TODO change the `cost_index` when we have our own cost table.
    let cost = native_gas(context.cost_table(), NativeCostIndex::SHA3_256, 1);

    let v = vdf::WesolowskiVDFParams(4096).new();

    let result = v.verify(&challenge, difficulty, &alleged_solution);
    // println!("vdf.rs result {:?}", result);
    let return_values = vec![Value::bool(result.is_ok())];
    Ok(NativeResult::ok(cost, return_values))
}
