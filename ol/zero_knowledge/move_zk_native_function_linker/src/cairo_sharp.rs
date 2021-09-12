use std::process::Command;
use std::process::Output;
use std::fs;


pub fn send_program(name_input: &String, val_input: u128) -> Output {
	const CAIRO_INPUT_PATH: &str = "cairo-prove-input.json";

	// Populate an input file (in JSON format) based on input to func
	let json_data = format!(
	r#"{{
		"name": "{}",
		"value": {}
	}}"#, 
		*name_input, 
		val_input
	);
	fs::write(CAIRO_INPUT_PATH, json_data).expect("Unable to write file: cairo-prove-input.json");

	//Sending cairo inforation to SHARP Prover
	let output = Command::new("cairo-sharp") //cairo-sharp submit --source prove_data.cairo     --program_input cairo-prove-input.json
        	.args(&["submit", "--source", "prove_data.cairo", "--program_input", "cairo-prove-input.json"])
			.output()
        	.expect("Failed to execute: cairo-sharp submit --source prove_data.cairo     --program_input cairo-prove-input.json ");


	/* DEBUGGING
	let mut output_s = String::from("");
	for int_o in output.stdout {
		output_s.push(int_o as char)
	}
	println!("{}", output_s);
	------------------ */

	return output;
}



pub fn parse_output(output: &Output) -> Result< (String, String), String > {
	/* --------------
	Parse out job key and fact (represented as Strings) 
	Contents of (Succesful) Output:
		Job key: Some_Hex_Val-Some_Hex_Val-Some_Hex_Val-Some_Hex_Val-Some_Hex_Val
		Fact: 0xSome_BIG_Hex_Val
	------------------ */
	// First look for "Job key: ", then read the following letters into job_key until a new line
	let mut first_check = String::from("");
	let mut start_key = 0;

	for i in 0..output.stdout.len() {
		first_check.push(output.stdout[i] as char);
		if first_check == "Job key: " {
			start_key = i+1;
			break;
		}
	}

	let mut job_key = String::from("");
	for i in start_key..output.stdout.len() {
		if output.stdout[i] as char == '\n' {
			start_key = i+1;
			break;
		}
		job_key.push(output.stdout[i] as char);
	}


	// Look for "Fact: ", then read the following hex into a string called fact
	let mut sec_check = String::from("");
	for i in start_key..output.stdout.len() {
		sec_check.push(output.stdout[i] as char);
		if sec_check == "Fact: " {
			start_key = i+1;
			break;
		}
	}

	let mut fact = String::from("");
	for i in start_key..output.stdout.len() {
		if output.stdout[i] as char == '\n' {
			break;
		}
		fact.push(output.stdout[i] as char);
	}

	/* ------ Parsing Done ------------ */


	if job_key.len() == 0 || fact.len() == 0 {
		let mut err = String::from("");
		for i in 0..output.stderr.len() {
			if output.stderr[i] as char == '\n' {
				break;
			}
			err.push(output.stderr[i] as char);
		}
		println!("Error Message: {}", err);
		//The value < x, it did not pass the Cairo assert
		//println!("No sufficent funds");
		return Err(String::from("No sufficent funds"));
	}

	return Ok( (fact, job_key) );
}

pub fn wait_for_processed_status(job_key: String) {
	let mut processed = false;
	while !processed {
		let output = Command::new("cairo-sharp") //cairo-sharp status JOB_KEY
        	.args(&["status", &job_key])
			.output()
        	.expect("Failed to execute: cairo-sharp status JOB_KEY ");
		
		
		if output.stderr.len() != 0 {
			// ------- Debugging
			let mut output_string = String::from("");
			for i in 0..output.stderr.len() {
				if output.stderr[i] as char == '\n' {
					break;
				}
				output_string.push(output.stderr[i] as char);
			}
			println!("output_string: {}",output_string );
			assert!(false);
		}

		let mut output_string = String::from("");
		for i in 0..output.stdout.len() {
			if output.stdout[i] as char == '\n' {
				break;
			}
			output_string.push(output.stdout[i] as char);
		}
		if output_string == String::from("PROCESSED") {
			processed = true;
		}
	}
}