use std::env;

use crate::ropsten_query;
use crate::cairo_sharp;
use cairo_verifier;

// Dependancies 
	// - Python 3.7.1, pip3 (Write installation in libra/scripts/dev_setup.sh)
	// - Cairo Lang Files (pip3 install cairo-lang-0.1.0.zip)
	

// Goal of Cairo Program is to prove and verifiy that the input's value is above x
#[tokio::main]
pub async fn verify(name_input: String, val_input: u128) -> bool {
	/* --------------
		Recording current driectory and switching to project_root/assests
	---------------- */
	let dir = env::current_dir().unwrap();
	let mut path = project_root::get_project_root().expect("Could not get project root"); //TODO: Return an error instead

	//Extra OL Path
	path.push("ol");
	path.push("zero_knowledge");
	path.push("move_zk_native_function_linker");

	path.push("assets");

	assert!(env::set_current_dir(path).is_ok());

	// DEBUGGING
	//let path_str = path.into_os_string().into_string().unwrap();
	//println!("{}", dir.display());


	/* -------------
		Sending Cairo Program to SHARP Prover
	--------------- */
	let output = cairo_sharp::send_program(&name_input, val_input);

	//Fail if sneding to SHARP Fails
	if !output.status.success() {
		println!("cairo unsuccessfully ran");
		//DEBUGGING
		let mut err_message = String::from("");
		for out_int in output.stderr {
			err_message.push(out_int as char);
		}
		println!("OUTPUT: {}", err_message);
		//--------------- */
		return false;
	}

	
	/* --------------
	Parse out job key and fact (represented as Strings) 
	Contents of (Succesful) Output:
		Job key: Some_Hex_Val-Some_Hex_Val-Some_Hex_Val-Some_Hex_Val-Some_Hex_Val
		Fact: 0xSome_BIG_Hex_Val
	------------------ */
	let res_output = cairo_sharp::parse_output(&output);
	let (fact, job_key) = match res_output {
		Ok((fact_tmp, key_tmp)) => (fact_tmp, key_tmp),
		Err(_error) 			=> return false,
	};


	// DEBUGGING
	println!("The parsed Job Key: {}", job_key);
	println!("The Parsed Fact: {}", fact);


	/* Wait until SHARP has generated the proof and sent it to the Ropsten Chain */
	cairo_sharp::wait_for_processed_status(job_key);


	/* ------------------
	Query the ETH Network (or use a yet-to be SHARP API) somehow to obtain a STARK Proof (Contain multiple programs)
	
	Option:
		Read each block registered on the Ropsten Chain (takes ~30 sec)
		Read each transaction in the pool and ensure that it's from SHARP's account # and to the Verification contract account #
		Decode the input of the transaction
	--------------------- */
	let encoded_proof = ropsten_query::get_encoded_proof().await.expect("Couldn't query Proof");
	let params = ropsten_query::decode_proof(&encoded_proof);

	// DEBUGGING
	println!("{:?}", params);

	//Pass proof to verifier. If there is no panic => proof is valid 
	// cairo_verifier::verify_proof(
	// 	proof_params, proof, task_meta_data,  cairo_aux_input, cairo_verifier_id
	// );

	//Revert back to original env's directory
	assert!(env::set_current_dir(dir).is_ok());

	return true;
}