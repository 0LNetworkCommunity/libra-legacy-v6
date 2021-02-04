// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

extern crate hex;

use zkp::rescue_verify;
use libra_types::{vm_status::{StatusCode}};
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::{Reference, Value},
};
use std::collections::VecDeque;
use vm::errors::{PartialVMError, PartialVMResult};

/// Rust implementation of Move function: 
// native public fun verify(
//     proof_hex:            &vector<u8>,
//     public_input_json:    &vector<u8>,
//     parameters_json:      &vector<u8>,
//     annotation_file_name: &vector<u8>
//   ) : bool;
// }
pub fn verify(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    if arguments.len() != 4 {
        let msg = format!(
            "wrong number of arguments for zkp::verify(), expected 4 found {}",
            arguments.len()
        );
        return Err(PartialVMError::new(StatusCode::UNREACHABLE).with_message(msg));
    }

    let annotation_file_name = pop_arg!(arguments, Reference).read_ref()?
        .value_as::<Vec<u8>>()?;
    let parameters_json = pop_arg!(arguments, Reference).read_ref()?
        .value_as::<Vec<u8>>()?;
    let public_input_json = pop_arg!(arguments, Reference).read_ref()?
        .value_as::<Vec<u8>>()?;        
    let proof_hex = pop_arg!(arguments, Reference).read_ref()?
        .value_as::<Vec<u8>>()?;        

    let proof_hex_str = &("0x".to_owned() + &hex::encode(&proof_hex))[..];
    let public_input_json_str = std::str::from_utf8(&public_input_json).unwrap();
    let parameters_json_str = std::str::from_utf8(&parameters_json).unwrap();
    let annotation_file_name_str = std::str::from_utf8(&annotation_file_name).unwrap();

    let result = rescue_verify(
        proof_hex_str, 
        public_input_json_str,
        parameters_json_str,
        annotation_file_name_str
    );

    // TODO change the `cost_index` when we have our own cost table.
    let cost = native_gas(context.cost_table(), NativeCostIndex::ZKP_VERIFY, 1);

    let return_values = vec![Value::bool(result)];
    Ok(NativeResult::ok(cost, return_values))
}