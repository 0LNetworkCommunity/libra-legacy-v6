use libra_types::transaction::authenticator;
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::{Reference, Value},
};
use libra_types::vm_error::{StatusCode, VMStatus};
use std::collections::VecDeque;
use std::convert::TryInto;
use vm::errors::VMResult;

// Extracts the first x bits of the auth_key which is the account address
// (at least for the POC). x is the length of AccountAddress
pub fn address_from_key(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> VMResult<NativeResult> {
    let mut auth_key_vec = pop_arg!(arguments, Reference)
    .read_ref()?
    .value_as::<Vec<u8>>()?;
    let auth_key_len = authenticator::AuthenticationKey::LENGTH;
    let mut auth_key_arr: [u8; authenticator::AuthenticationKey::LENGTH] = 
         [0; authenticator::AuthenticationKey::LENGTH];
    for i in 0..auth_key_len {
        auth_key_arr[i] = auth_key_vec.remove(0);
    };
    let auth_key = authenticator::AuthenticationKey::new(auth_key_arr);
    let address = auth_key.derived_address();
    
    let cost = native_gas(context.cost_table(), NativeCostIndex::PARSE_AUTH_KEY, 1);
    let return_values = vec![Value::address(address)];
    Ok(NativeResult::ok(cost, return_values))
}