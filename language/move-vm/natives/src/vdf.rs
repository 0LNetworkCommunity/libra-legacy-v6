// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0
use vdf::{VDFParams, VDF};
use libra_types::transaction::authenticator::AuthenticationKey;
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::{Reference, Value},
};

use libra_types::vm_error::{StatusCode, VMStatus};
use std::collections::VecDeque;
use std::convert::TryFrom;
use vm::errors::VMResult;
use hex;

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
    
    // let pre = hex::decode("d68330e03790185319b7487baad0645a03051738f841c411f293dd7779d39eb1");

    // let sol = hex::decode("0051700e5bde2f2e95092aef52b05e2faf9c862bb224f88b8c83e907bbb76a7c5704e132620c9f5e439e4d2cdf73ab2a820b70893c0dba4aa52f5f745810b88843d7fd73ed37d4b61be2be9861d0f06aaa50db7f3402f9ff720cec04067120d033d85843e9e83514294f0d6b3e9a78744c2c4174704cb303a5b0f08debb8f1d0c6d29b6591493b152e99401ba18c93040bc3bf3a2ad4f1e95a7604454c0db3c79cb49c52c591e9d251f0bf074fa629732215d85749fbcb66004717df79f40fc3dde718f945d01491d6fb386d67132c2cc9e6c0fa590356d9afaad7c81128fdcc3bcc07d646c6031dc081b41df756e2b2d4b90f767a8e577a6bdfecf1d8bae5a51b00102adb2c2c688b6b998de27b0afb275277cf4f7fe6971579d8e50b274209c279f4c14ab21aac5d18f1f535fe844a86e8c141120bd79047880bb9f2f66253b2e1e74fb6ba0b951d4441f132e7bd7040a1d9a45ebb63b7486fbe269299e63977975bb98f8fecc3977f583a3e2ecfef6e5f0a5113ac064731f73211336c6daed2d0b931ecb409bb72bea803c47edac2517ecb46a46414f110ac9dfb1ebdc7ed8066a30461444a6e78e551d68b51dbe965e6707f70b9b12e2de2460cd9b54b0693dffc3fb597d89dfe4856fb20bb58f56979555858328a69f7f465d8984524a53707ca9c71b2a973092b5071946c1f4df9b8e88a2bc36f5eac57ccab9856ee0b4c3f006276692ee803a2cb50db467d6ae2a91b230c10f6c8c2c6ed287c8717dc057a2a221ef7c322b306e6d4bd8978e5e7b95c8b6389e2d4b610e91aad5ab539b3deecaa18148e8a6542e70c0629d647b42e9628efa6b34750a4d4ac688b21b91dbb57dc84b618ae57f565a51a2eed1a08da3b8aae8826fb6268871f302504a42743b5c8132baa7f1812dc0f10ae1510a8653895461836c355198bc46e6a496e2a298b6ad466a50ac5aa47502356f579594ffdfda6657e7855839b205a50ca9899f22c49e79a2cd7bc0ffc758c98345877d4e70e5a61df123450ef4b8756ac29414d35c2a647cd465957af9363eddfe20041676697e7a339eedf5a8ab000d8b354a99bffc38d07cbd0f4d612fce6d1c997aafde7efa622ecef335ec34ee9e4644ceea33a782ca5a35e4f3e73694cf4bc6f0ac8d410b1092992547b4638d0c6f16d9378369426f7dc4881d464293100e9349f02b4c49c1b025575510b1924ef9938b19d407ebbdc84f18a680769a6e10b0ad66067e05bf006d14d0932b1bf99cd8c592c3295c95159658d74fe15c078dab50dcc913581e52c050c170e736e604211d795f4a3bb3a3f372d1c713c21f57358449335ae35c50b9bb1af599b008db37285c6d2fa40f1c710c31ea27e2b7a31007366b49560f81c4ffcf672a23ce1badc05cd4e33db381352f6fea4aa0a49ae8eb821ad6356a5c329a2518c1e43da8433292f17");
    // let result = v.verify(&pre, 2400000, &sol);

    println!("vdf.rs - challenge: {}", hex::encode(&challenge));
    println!("vdf.rs - difficulty: {:?}", &difficulty);


    let result = v.verify(&challenge, difficulty, &alleged_solution);

    println!("vdf.rs - result: {:?}", result);

    let return_values = vec![Value::bool(result.is_ok())];
    Ok(NativeResult::ok(cost, return_values))
}

// Extracts the first 32 bits of the vdf challenge which is the auth_key
// Auth Keys can be turned into an AccountAddress type, to be serialized to a move address type.
pub fn extract_address_from_challenge(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> VMResult<NativeResult> {
    let cost = native_gas(context.cost_table(), NativeCostIndex::PARSE_AUTH_KEY, 1);

    let challenge_vec = pop_arg!(arguments, Reference)
        .read_ref()?
        .value_as::<Vec<u8>>()?;

    // println!("pub_key_vec\n{:?}", hex::encode(&challenge_vec));

    let auth_key_vec = &challenge_vec[..32];
    // let len = auth_key_vec.len();
    // println!("len\n{:?}", &len);

    // TODO: Error handle on wrong size.
    // if len < 32 {
    //     return Err(NativeResult::err(
    //         cost,
    //         VMStatus::new(StatusCode::NATIVE_FUNCTION_ERROR)
    //             .with_sub_status(DEFAULT_ERROR_CODE),
    //     ));
    // };

    let auth_key = AuthenticationKey::try_from(auth_key_vec).expect("Check length");
    let address = auth_key.derived_address();
    // println!("address\n{:?}", &address);
    let return_values = vec![Value::address(address), Value::vector_u8(auth_key_vec[..16].to_owned())];
    Ok(NativeResult::ok(cost, return_values))
}
