//////// 0L ////////
// SPDX-License-Identifier: Apache-2.0
use move_binary_format::errors::{PartialVMError, PartialVMResult};
use move_core_types::vm_status::StatusCode;
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::Value,
};
use rust_decimal::{self, Decimal, MathematicalOps, prelude::ToPrimitive};
use smallvec::smallvec;
use std::collections::VecDeque;

pub fn native_decimal_demo(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 3);

    // pop arguments in reverse order
    let scale = pop_arg!(arguments, u8) as u32;
    let mut signed_int = pop_arg!(arguments, u128) as i64;
    let sign = pop_arg!(arguments, bool);

    if !sign {
        signed_int = signed_int * -1
    }

    let dec = Decimal::new(signed_int, scale);

    let new_sign = dec.is_sign_positive();
    let new_int = dec.mantissa();
    let new_scale = dec.scale();

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::DECIMAL,
        signed_int.to_be_bytes().len(),
    );

    Ok(NativeResult::ok(
        cost,
        smallvec![
            Value::bool(new_sign),
            Value::u128(new_int as u128),
            Value::u8(new_scale as u8)
        ],
    ))
}

pub fn native_decimal_single(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 4);

    // pop arguments in reverse order
    let scale = pop_arg!(arguments, u8) as u32;
    let mut signed_int = pop_arg!(arguments, u128) as i64;
    let sign = pop_arg!(arguments, bool);
    let op_id = pop_arg!(arguments, u8);

    if !sign {
        signed_int = signed_int * -1
    }

    let dec = Decimal::new(signed_int, scale);

    let result = match op_id {
        5 => dec.sqrt().unwrap().normalize(),
        _ => return Err(PartialVMError::new(StatusCode::INDEX_OUT_OF_BOUNDS)),
    };

    let new_sign = result.is_sign_positive();
    let new_int = result.mantissa();
    let new_scale = result.scale();

    let cast_new_int = new_int as u128;
    let cast_new_scale = new_scale as u8;

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::DECIMAL,
        signed_int.to_be_bytes().len(),
    );

    Ok(NativeResult::ok(
        cost,
        smallvec![
            Value::bool(new_sign),
            Value::u128(cast_new_int),
            Value::u8(cast_new_scale)
        ],
    ))
}

pub fn native_decimal_pair(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 8);

    // pop arguments in reverse order
    let scale_right = pop_arg!(arguments, u8) as u32;
    let mut signed_int_right = pop_arg!(arguments, u128) as i64;
    let sign_right = pop_arg!(arguments, bool);
    if !sign_right {
        signed_int_right = signed_int_right * -1
    }

    let scale_left = pop_arg!(arguments, u8) as u32;
    let mut signed_int_left = pop_arg!(arguments, u128) as i64;
    let sign_left = pop_arg!(arguments, bool);
    if !sign_left {
        signed_int_left = signed_int_left * -1
    }

    let _rounding_strategy = pop_arg!(arguments, u8);
    let op_id = pop_arg!(arguments, u8);

    let mut dec_left = Decimal::new(signed_int_left, scale_left);
    let dec_right = Decimal::new(signed_int_right, scale_right);

    let result = match op_id {
        0 => { dec_left.rescale(signed_int_right as u32); dec_left },
        1 => dec_left.checked_add(dec_right).unwrap().normalize(),
        2 => dec_left.checked_sub(dec_right).unwrap().normalize(),
        3 => dec_left.checked_mul(dec_right).unwrap().normalize(),
        4 => dec_left.checked_div(dec_right).unwrap().normalize(),
        5 => {
          let pow = dec_right.to_f64().unwrap();
          dec_left.powf(pow).normalize()
        },

        _ => return Err(PartialVMError::new(StatusCode::INDEX_OUT_OF_BOUNDS)),
    };

    let new_sign = result.is_sign_positive();
    let new_int = result.mantissa();
    let new_scale = result.scale();

    let cast_new_int = new_int as u128;
    let cast_new_scale = new_scale as u8;

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::DECIMAL,
        signed_int_left.to_be_bytes().len(),
    );

    Ok(NativeResult::ok(
        cost,
        smallvec![
            Value::bool(new_sign),
            Value::u128(cast_new_int),
            Value::u8(cast_new_scale)
        ],
    ))
}
