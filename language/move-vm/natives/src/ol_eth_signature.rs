// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use move_binary_format::errors::PartialVMResult;
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::Value,
};
use smallvec::smallvec;
use std::{collections::VecDeque, convert::TryFrom};

pub fn native_eth_signature_recover(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 2);

    let msg_bytes = pop_arg!(arguments, Vec<u8>);
    let sig_bytes = pop_arg!(arguments, Vec<u8>);

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::ETH_SIGNATURE_RECOVER,
        msg_bytes.len(),
    );

    let sig = match ethers::core::types::Signature::try_from(sig_bytes.as_slice()) {
        Ok(sig) => sig,
        Err(_) => {
            return Ok(NativeResult::ok(
                cost,
                smallvec![Value::vector_u8(vec![0u8; 20])],
            ));
        }
    };

    let pubkey = match sig.recover(msg_bytes.as_slice()) {
        Ok(pubkey) => pubkey,
        Err(_) => {
            return Ok(NativeResult::ok(
                cost,
                smallvec![Value::vector_u8(vec![0u8; 20])],
            ));
        }
    };

    Ok(NativeResult::ok(
        cost,
        smallvec![Value::vector_u8(pubkey.as_bytes().to_vec())],
    ))
}

pub fn native_eth_signature_verify(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 3);

    let msg_bytes = pop_arg!(arguments, Vec<u8>);
    let pubkey_bytes = pop_arg!(arguments, Vec<u8>);
    let sig_bytes = pop_arg!(arguments, Vec<u8>);

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::ETH_SIGNATURE_VERIFY,
        msg_bytes.len(),
    );

    if pubkey_bytes.len() != 20 {
        return Ok(NativeResult::ok(cost, smallvec![Value::bool(false)]));
    }

    let sig = match ethers::core::types::Signature::try_from(sig_bytes.as_slice()) {
        Ok(sig) => sig,
        Err(_) => {
            return Ok(NativeResult::ok(cost, smallvec![Value::bool(false)]));
        }
    };

    let pubkey = ethers::core::types::H160::from_slice(pubkey_bytes.as_slice());

    let verify_result = sig.verify(msg_bytes.as_slice(), pubkey).is_ok();
    Ok(NativeResult::ok(
        cost,
        smallvec![Value::bool(verify_result)],
    ))
}
