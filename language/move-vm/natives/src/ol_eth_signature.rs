// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use diem_crypto::{ed25519, traits::*};
use move_binary_format::errors::PartialVMResult;
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::Value,
};
use smallvec::smallvec;
use std::{collections::VecDeque, convert::TryFrom};
use ethers::core::types::Signature; 

use std::{thread, time};

pub fn native_eth_signature_recover(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 2);

    //let ten_millis = time::Duration::from_millis(4000);

    //thread::sleep(ten_millis);

    let sig_bytes = pop_arg!(arguments, Vec<u8>);
    let msg_bytes = pop_arg!(arguments, Vec<u8>);

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::ETH_SIGNATURE_RECOVER,
        msg_bytes.len(),
    );

    let sig = match ethers::core::types::Signature::try_from(&sig_bytes[..]) {
        Ok(sig) => sig,
        Err(_) => {
            return Ok(NativeResult::ok(cost, smallvec![Value::bool(false)]));
        }
    };

    let pub_key = match sig.recover(&msg_bytes[..]) {
        Ok(pub_key) => pub_key,
        Err(_) => {
            return Ok(NativeResult::ok(cost, smallvec![Value::bool(false)]));
        }
    };

    Ok(NativeResult::ok(
        cost,
        smallvec![Value::vector_u8(pub_key.as_bytes().to_vec())],
    ))
}

pub fn native_eth_signature_verify(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 1);

    let msg = pop_arg!(arguments, Vec<u8>);
/*
    let pubkey = pop_arg!(arguments, Vec<u8>);
    let signature = pop_arg!(arguments, Vec<u8>);
*/

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::ETH_SIGNATURE_VERIFY,
        msg.len(),
    );


    Ok(NativeResult::ok(
        cost,
        smallvec![Value::bool(true)],
    ))
}
