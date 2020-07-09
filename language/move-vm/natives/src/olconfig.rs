// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::{Reference, Value},
};

use libra_types::{ 
    vm_error::{StatusCode, VMStatus},
    ol_config
};
use std::collections::VecDeque;
use vm::errors::VMResult;

/// Rust implementation of Move's `native public fun get_ol_u64constant(env: u64, constant: u64): u64`
/// Considering env: 0 is test and 1 to be prod
pub fn get_ol_u64constant(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> VMResult<NativeResult> {
    if arguments.len() != 2 {
        let msg = format!(
            "wrong number of arguments for get_ol_u64constant expected 2 found {}",
            arguments.len()
        );
        return Err(VMStatus::new(StatusCode::UNREACHABLE).with_message(msg));
    }

    // Getting constant value (Currently u64 as index value)
    // TODO::Change format to HEX
    let constant = pop_arg!(arguments, u64);
    // Getting the environment 
    let env = pop_arg!(arguments, u64);

    // TODO change the `cost_index` when we have our own cost table.
    let cost = native_gas(context.cost_table(), NativeCostIndex::GETOLU64CONSTANT, 1);

    println!("Environment value {}", env);

    let msg = format!(
        "invalid arguments for get_ol_u64constant {}",
        arguments.len()
    );

    match env {
        0 => {
            match constant {
                0 => Ok(NativeResult::ok(cost, vec![Value::u64(ol_config::test::EPOCH_LENGTH)])),
                _ => Err(VMStatus::new(StatusCode::INVALID_DATA).with_message(msg))
            }
        },
        1 => {
            match constant {
                0 => Ok(NativeResult::ok(cost, vec![Value::u64(ol_config::prod::EPOCH_LENGTH)])),
                _ => Err(VMStatus::new(StatusCode::INVALID_DATA).with_message(msg))
            }
        },
        _ => Err(VMStatus::new(StatusCode::INVALID_DATA).with_message(msg))
    }
}
