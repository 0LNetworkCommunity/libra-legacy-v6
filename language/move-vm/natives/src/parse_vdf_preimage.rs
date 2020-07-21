use libra_types::transaction::authenticator::*;
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::{Reference, Value},
};
use std::collections::VecDeque;
use vm::errors::VMResult;
use std::convert::TryFrom;
use libra_types::vm_error::{VMStatus, StatusCode};
use crate::signature::DEFAULT_ERROR_CODE;

// Extracts the first 32 bits of the vdf challenge which is the auth_key
// Auth Keys can be turned into an AccountAddress type, to be serialized to a move address type.
pub fn address_from_challenge(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> VMResult<NativeResult> {
    let cost = native_gas(context.cost_table(), NativeCostIndex::PARSE_AUTH_KEY, 1);

    let challenge_vec = pop_arg!(arguments, Reference)
    .read_ref()?
    .value_as::<Vec<u8>>()?;

    let len = challenge_vec.len();
    if len < 32 {
        return Ok(NativeResult::err(
            cost,
            VMStatus::new(StatusCode::NATIVE_FUNCTION_ERROR)
                                        .with_sub_status(DEFAULT_ERROR_CODE),
            )
        );
    };

    let auth_key_vec = &challenge_vec[..32];
    let auth_key = AuthenticationKey::try_from(auth_key_vec).expect("Check length");
    let address = auth_key.derived_address();
    let return_values = vec![Value::address(address), Value::vector_u8(auth_key_vec[..16].to_owned())];
    Ok(NativeResult::ok(cost, return_values))
}
