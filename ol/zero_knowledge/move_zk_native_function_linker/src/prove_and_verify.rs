use std::env;

use crate::ropsten_query;
use crate::cairo_sharp;
use cairo_verifier::verify_proof as cairo_verifier;
use num256::uint256::Uint256 as Uint256;


// Dependancies 
	// - Python 3.7.1, pip3 (Write installation in libra/scripts/dev_setup.sh)
	// - Cairo Lang Files (pip3 install cairo-lang-0.1.0.zip)
	

// Goal of Cairo Program is to generate a proof that x is above a certain value
// Returns bytes of: proof, proofParams, cairoAuxInput, taskMetaData, fact (String)
#[tokio::main]
pub async fn prove(name_input: String, val_input: u128) -> (Vec<u8>, Vec<u8>, Vec<u8>, Vec<u8>, Vec<u8>) {
	/* --------------
		Recording current driectory and switching to project_root/assests
	---------------- */
	let dir = env::current_dir().unwrap();
	let mut path = project_root::get_project_root().expect("Could not get project root");

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
		let empty: Vec<u8> = vec![];
		return (empty.clone(), empty.clone(), empty.clone(), empty.clone(), empty.clone());
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
		Err(_error) 			=> {
			let empty: Vec<u8> = vec![];
			return (empty.clone(), empty.clone(), empty.clone(), empty.clone(), empty.clone());
		},
	};


	// DEBUGGING
	// println!("The parsed Job Key: {}", job_key);
	// println!("The Parsed Fact: {}", fact);


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
	//TODO: Above function times out at 7 minutes but potentially it can take up to 24 hours. Soln. Ask Starkware for a seperate queue in the prover

	let params = ropsten_query::decode_proof(&encoded_proof).expect("Couldn't decode proof");

	// DEBUGGING
	// let params = ropsten_query::sample_proof().await;
	// let fact = String::from("");
	// println!("params: {:?}",params);


	let reader_map = params.named_params;

	//Read and convert proof
	let proof_ethabi = &reader_map["proof"].clone().value;
	let proof: Vec<Uint256> = convert_to_uint256(proof_ethabi);

	//Read and convert proofParams
	let proof_params_ethabi = &reader_map["proofParams"].clone().value;
	let proof_params: Vec<Uint256> = convert_to_uint256(proof_params_ethabi);

	//Read and convert cairoAuxInput
	let cairo_ethabi = &reader_map["cairoAuxInput"].clone().value;
	let cairo_aux: Vec<Uint256> = convert_to_uint256(cairo_ethabi);

	//Read and convert taskMetadata
	let task_ethabi = &reader_map["taskMetadata"].clone().value;
	let task_meta: Vec<Uint256> = convert_to_uint256(task_ethabi);


	//Revert back to original env's directory
	assert!(env::set_current_dir(dir).is_ok());

	//Reformat params into a vector of Uint256 then Reformat into fixed bytes
	let proof_bytes = bytes_of_vec_uint256(&proof);
	let proof_params_bytes = bytes_of_vec_uint256(&proof_params);
	let cairo_aux_bytes = bytes_of_vec_uint256(&cairo_aux);
	let task_metadata_bytes = bytes_of_vec_uint256(&task_meta);
	let fact_bytes = bytes_of_string(fact);


	return (proof_bytes, proof_params_bytes, cairo_aux_bytes, task_metadata_bytes, fact_bytes);
}





//Verifies the data (generated above) by using a Cairo ZK-STARK Verifier
pub fn verify(proof_bytes: &Vec<u8>, proof_prams_bytes: &Vec<u8>, cairo_aux_bytes: &Vec<u8>, task_bytes: &Vec<u8>, fact_bytes: &Vec<u8>) -> bool {

	//Reconstruct inputs to proper form
	let proof: Vec<Uint256> = reconstruct_vec256_from_bytes(&proof_bytes);
	let proof_params: Vec<Uint256> = reconstruct_vec256_from_bytes(&proof_prams_bytes);
	let cairo_aux_input = reconstruct_vec256_from_bytes(&cairo_aux_bytes);
	let task_meta_data = reconstruct_vec256_from_bytes(&task_bytes);

	//Reconstruct fact from string bytes
	let mut fact = String::from("");
	for code_ascii in fact_bytes {
		fact.push(*code_ascii as char);
	}

	//Pass proof to verifier. If there is no panic => proof is valid 
	cairo_verifier::verify_proof(
		proof_params, proof, task_meta_data,  cairo_aux_input, get_uint256(&fact[..])
	);

	return true;
}





//Helper functions for converting Bytes <-> Uint256 <-> ethereumAbi::Value

fn bytes_of_vec_uint256(orig_data: &Vec<Uint256>) -> Vec<u8> {
	let mut data: Vec<u8> = vec![];

	for num in orig_data {
		let bytes_num = to_fixed_bytes(&num);
		for byte in &bytes_num {
			data.push( *byte );
		}
	}

	return data;
}

fn bytes_of_string(string: String) -> Vec<u8> {
	let mut data: Vec<u8> = vec![];

	for char in string.chars() {
		data.push( char as u8 );
	}

	return data;
}

fn reconstruct_vec256_from_bytes(data: &Vec<u8>) -> Vec<Uint256>{
	let mut converted_data: Vec<Uint256> = vec![];
	for i in 0..(data.len()/32) { //32 Bytes = Uint256
		//Get 32 prev bytes (including bytes[i] and -> Uint256)
		let mut bytes: [u8; 32] = [0; 32];
		for j in 0..32 {
			bytes[j] = data[ 32 * i + j ];
		}
		converted_data.push( Uint256::from_bytes_be(&bytes) );
	}

	return converted_data;
}

fn get_uint256(str: &str) -> Uint256 {
    let mut string_even = String::from(str);
    if str.len() % 2 != 0 { //If length is odd, prepend a 0
        let mut zero_string = String::from("0");
        zero_string.push_str(str);
        string_even = zero_string.clone();
    }

    let val_bytes = hex::decode(string_even).expect("Whoops problem encoding str to hex: ");
    return Uint256::from_bytes_be(&val_bytes);
}

fn to_fixed_bytes(val: & Uint256) -> [u8; 32] {
    let mut fixed_bytes: [u8; 32] = [0; 32];
    let val_bytes = val.to_bytes_be();
    for i in 0..val_bytes.len() {
        fixed_bytes[32 - val_bytes.len() + i] = val_bytes[i];
    }
    return fixed_bytes;
}

fn convert_to_uint256(value: &ethereum_abi::Value) -> Vec<Uint256> {
	let mut data: Vec<Uint256> = vec![];

	match value {
		ethereum_abi::Value::Array(values, _) => {
			for val in values {
				let num: [ethereum_abi::Value; 1] = [val.clone()];
				data.push( Uint256::from_bytes_be( &ethereum_abi::Value::encode(&num) ) );
			}	
		},
		_ => assert!(false),
	}
	
	return data;
}