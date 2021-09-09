use std::time::{SystemTime, UNIX_EPOCH};
use std::fs::File;
use ethereum_abi::Abi;
use web3::types::BlockId;
use web3::types::U64;
use ethereum_abi::DecodedParams;


/* ------------------
	Query the ETH Network (or use a yet-to be SHARP API) somehow to obtain a STARK Proof (Contain multiple programs)
	
	Option 1:
		Read each block registered on the Ropsten Chain (takes ~30 sec)
		Read each transaction in the pool and ensure that it's from SHARP's account # and to the Verification contract account #
	--------------------- */
pub async fn get_encoded_proof() -> Result<String, String> {
	let mut encoded_input: String = String::from("");

	//Setup Connection to Ropsten Node
	let transport = web3::transports::Http::new("https://ropsten.infura.io/v3/7dbfcd40a78f4385918989b2b058f313").expect("Could not connect to Ropsten Node");
	let web3 = web3::Web3::new(transport);

	//Represent const account addreses as Vec<u8>
	let account_sharp = String::from("723cd86dc2295d31fd5042367dd52093e799b168");
	let acount_verifier = String::from("2886D2A190f00aA324Ac5BF5a5b90217121D5756");
	let starkware_addr = hex::decode(account_sharp).expect("Whoops");
	let verifier_addr = hex::decode(acount_verifier).expect("Whoops");
	//let starkware_addr = account_sharp.as_bytes();
	//let verifier_addr = acount_verifier.as_bytes();

	let mut cont_read = true;
	let mut prev_block_num: U64 = U64::from(0);

	let mut time_elapsed: u128 = 0;
	let max_sharp_time: u128 = 420 * 1000; // 7 min (Measured in ms)

	//println!("Succesfully setup Ropsten node");
	
	//Limit querying time to 7 min or when we get the input
	while time_elapsed < max_sharp_time && cont_read {
		let time_start = SystemTime::now().duration_since(UNIX_EPOCH).expect("Time went backwards");

		//Get identifier of latest block
		let curr_block_num: U64 = web3.eth().block_number().await.expect("Could not get block number");

		if prev_block_num != curr_block_num {
			//Get transaction pool within block as a vector
			let block = web3.eth().block_with_txs( BlockId::from(curr_block_num) ).await
				.expect("Could not get block transactions");
			let unwrapped_tx = match block {
				Some(x) => x,
				None	=> continue,
			};
			let txns = unwrapped_tx.transactions;

			//Check if it is the right contract, if so get the input
			for tx in txns {
				let from_addr = tx.from.as_bytes();
				let to = match tx.to {
					Some(x) => x,
					None    => continue,
				};
				let to_addr = to.as_bytes();
				
				//---- DEBUGGING
				//let addr_string = hex::encode(from_addr);
				//println!("Transaction #: {}", addr_string);

				if from_addr == starkware_addr && to_addr == verifier_addr {
					encoded_input = hex::encode(tx.input.0);
					println!("Found you! {}", encoded_input);
					cont_read = false;
					break;
				}
			}
		}

		//Update time and block looked at
		let delta_t = SystemTime::now().duration_since(UNIX_EPOCH).expect("Time went backwards") - time_start;
		time_elapsed += delta_t.as_millis();
		prev_block_num = curr_block_num;
	}
	//If timeout return Error
	if cont_read {
		return Err(String::from("Timed out on cheking for txn"));
	}
	//Otherwise return encode inout
	return Ok(encoded_input);
}




/* -----------
	Converint Hex-String Decoded Input -> Decode Dictionary basically
 ------------- */
pub fn decode_proof(proof: & String) -> Result<DecodedParams, String> {
	//Decode input using contract_abi.json
	let abi = {
		let file = File::open("contract_abi.json").expect("failed to open ABI file");

		Abi::from_reader(file).expect("failed to parse ABI")
	};

	let (_, decoded_input) = abi
		.decode_input_from_hex(proof.trim())
		.expect("failed decoding input");

	
	// --DEBUGGING
	//println!("{:?}", decoded_input); //decoded_input.0 -> Vec<DecodedParam>
	// Decoded param: Param (Contains String, Type [Enum]), and a value: Value (Type [Enum])
	// proof: Vec<u256> = decoded_input.0[i].value as? Vec<u8>

	return Ok(decoded_input);
}