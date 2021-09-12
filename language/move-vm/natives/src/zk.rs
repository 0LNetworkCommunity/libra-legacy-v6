use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::Value,
};
use libra_types::vm_status::{StatusCode};
use vm::errors::{PartialVMError, PartialVMResult};
use std::collections::VecDeque;
use zero_knowledge::prove_and_verify as zk;

/* The connecting function to the MOVE instruction set */
pub fn verify(
    context: &impl NativeContext,
    ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    if ty_args.len() != 0 {
        let msg = format!( "ty_args len should be 0, not {}", ty_args.len() );
        return Err(PartialVMError::new(StatusCode::UNREACHABLE).with_message(msg));
    }

	if args.len() != 5 {
        let msg = format!( "wrong number of arguments for verify expected 4 found {}", args.len() );
        return Err(PartialVMError::new(StatusCode::UNREACHABLE).with_message(msg));
    }

	//Get inputs
	let fact = pop_arg!(args, Vec<u8>);
    let cairo_aux_input = pop_arg!(args, Vec<u8>);
	let task_meta_data = pop_arg!(args, Vec<u8>);
	let proof_params = pop_arg!(args, Vec<u8>);
	let proof = pop_arg!(args, Vec<u8>);

	//TODO: Estimate properly in libra/language/tools/vm-genesis/src/genesis_gas_schedule.rs
	// Calculate gas cost based on estimate at: libra/language/tools/vm-genesis/src/genesis_gas_schedule.rs
    let cost = native_gas(context.cost_table(), NativeCostIndex::ZK_VERIFY, 1);


	//Call STARK Verification located at: libra/ol/zero_knowledge
	let success = zk::verify(&proof, &proof_params, &task_meta_data, &cairo_aux_input, &fact);

	//Return success boolean to Move
    Ok(NativeResult::ok(cost, vec![Value::bool(success)]))
}

/* The connecting function to the MOVE instruction set */
pub fn prove(
    context: &impl NativeContext,
    ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    if ty_args.len() != 0 {
        let msg = format!( "ty_args len should be 0, not {}", ty_args.len() );
        return Err(PartialVMError::new(StatusCode::UNREACHABLE).with_message(msg));
    }
	if args.len() != 2 {
        let msg = format!( "wrong number of arguments for verify expected 2 found {}", args.len() );
        return Err(PartialVMError::new(StatusCode::UNREACHABLE).with_message(msg));
    }

	//Get inputs
    let value = pop_arg!(args, u128);
	let name_vec = pop_arg!(args, Vec<u8>);

	//Convert name_vec: Vec<u8> -> name: String (ASCII)
	let mut name = String::from("");
	let error = convert_to_string(name_vec, &mut name);
	if error { //Abort transaction with "name contains non-printable ascii characters" (TODO: Maybe switch type of error returned?)
		let msg = format!( "Error: name contains non-printable ascii-characters", );
        return Err(PartialVMError::new(StatusCode::UNREACHABLE).with_message(msg)); 
	}


	//TODO: Estimate properly in libra/language/tools/vm-genesis/src/genesis_gas_schedule.rs
	// Calculate gas cost based on estimate at: libra/language/tools/vm-genesis/src/genesis_gas_schedule.rs
    let cost = native_gas(context.cost_table(), NativeCostIndex::ZK_PROVE, 1);


	//Call STARK Verification located at: libra/ol/zero_knowledge
	let (proof, proof_params, cairo_aux_input, task_meta_data, fact) = zk::prove(name, value);

	//Return success boolean to Move
    Ok(NativeResult::ok(cost, vec![
			Value::vector_u8(proof), Value::vector_u8(proof_params), Value::vector_u8(cairo_aux_input), Value::vector_u8(task_meta_data), Value::vector_u8(fact)
		]
	))
}

//// --------- Helper Function
fn convert_to_string(name_vec: Vec<u8>, name: &mut String ) -> bool {
	let mut error = false;
	for code_ascii in name_vec {
		if !(code_ascii >= 32 && code_ascii <= 126) {
			error = true;
			break;
		}
		name.push(code_ascii as char);
	}

	return error;
}