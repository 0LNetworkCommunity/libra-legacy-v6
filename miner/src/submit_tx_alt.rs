//! OlMiner submit_tx module
#![forbid(unsafe_code)]

use crate::error::{Error, ErrorKind};
use cli::client_proxy::ClientProxy;
use libra_types::{waypoint::Waypoint};
use std::fs::File;
use std::io::BufReader;
use libra_json_rpc_types::views::MinerStateView;
use std::path::Path;
use serde::{Serialize, Deserialize};

// use crate::application::{MINER_MNEMONIC, DEFAULT_PORT};
// const DEFAULT_PORT: u64 = 2344; // TODO: this will likely deprecated in favor of urls and discovery.
                                // const DEFAULT_NODE: &str = "src/config/test_data/single.node.config.toml";
// TODO: I don't think this is being used
// const ASSOCIATION_KEY_FILE: &str = "../0_dev_config/mint.key"; // Empty String or invalid file get converted to a None type in the constructor.
struct TxParams {
    url: Url,
    waypoint: Waypoint,
    keypair: KeyPair,
    max_gas_unit_for_tx: u64,
    coin_price_per_unit: u64,
    user_tx_timeout: u64, // for compatibility with UTC's timestamp.
}

// impl Default for Txparams{ 
//     fn default(){

//     }
// }

pub fn test_runner () {
    // PathBuf.new("./blocks")
    let is_test = true
    if is_test {
        let (preimage, proof) = get_block_fixtures();
        let tx_params = get_params_from_fixtures();
        submit_tx(tx_params: TxParams, preimage, proof);

        // get preimage and proof
        
    }


}


fn submit_tx(tx_params: TxParams, preimage: Vec<u8>, proof: Vec<u8>) -> Result<String, Error> {


    // Create a client object
    let mut client = LibraClient::new(tx_params.url,tx_params.waypoint).unwrap();

    let account_state = client.get_account_state(tx_params.address.clone(), true).unwrap();
    dbg!(&account_state);


    let mut sequence_number = 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }
    dbg!(&sequence_number);

    // Create the unsigned MinerState transaction script
    let script = Script::new(
        transaction_scripts::StdlibScript::Redeem.compiled_bytes().into_vec(),
        vec![],
        vec![
            TransactionArgument::U8Vector(challenge),
            TransactionArgument::U64(delay_difficulty()),
            TransactionArgument::U8Vector(proof),
            TransactionArgument::U64(tower_height as u64),
        ],
    );

    // sign the transaction script
    let txn = create_user_txn(
        &keypair,
        TransactionPayload::Script(script),
        address,
        sequence_number,
        700_000,
        0,
        "GAS".parse()?,
        5000000, // for compatibility with UTC's timestamp.
    )?;

    // Plz Halp  (ZM):
    // get account_data struct
    let mut sender_account_data = AccountData {
        address,
        authentication_key: Some(auth_key.to_vec()),
        key_pair: Some(keypair),
        sequence_number,
        status: AccountStatus::Persisted,
    };

    dbg!(&sender_account_data);
    // Plz Halp (ZM):
    // // Submit the transaction with libra_client
    match client.submit_transaction(
        Some(&mut sender_account_data),
        txn
    ){
        Ok(_) => {
            ol_wait_for_tx(address, sequence_number, &mut client);
            Ok("Tx submitted".to_string())

        }
        Err(err) => Err(err)
    }
}

fn get_params_from_mnemonic () -> Result<TxParams, Error> {
    unimplemented!();
}

fn get_params_from_swarm () -> Result<TxParams, Error> {
    // let miner_configs = app_config();
    
    let mut private_key = config.test.unwrap().operator_keypair.unwrap();
    let auth_key = AuthenticationKey::ed25519(&private_key.public_key());

    let address = auth_key.derived_address();


    let url =  Url::parse(format!("http://localhost:{}", config.rpc.address.port()).as_str()).unwrap()
    // let url: Result<Url, Error> = miner_configs.chain_info.node;
    let parsed_waypoint: Result<Waypoint, Error> = config.base.waypoint.waypoint_from_config().unwrap().clone()
    
    //unwrap().parse::<Waypoint>();
    let keypair = KeyPair::from(private_key.take_private().clone().unwrap());
    dbg!(&keypair);
    let tx_params = TxParams {
        
    }

    Ok(tx_params)
}

fn get_params_from_fixtures () -> Result<TxParams, Error> {
    let url = 
    waypoint = "0:123"; // get from swarm.

    
    TxParams {
        "localhost:8080".parse(); // get URL from swarm.,
        "0:123", // get from swarm
        keypair: KeyPair, // get from string.
        max_gas_unit_for_tx: 1_000_000,
        coin_price_per_unit: 0,
        user_tx_timeout: 5_000,
    }

}

fn get_block (height: u64) -> (preimage: Vec<u8>, proof:  Vec<u8>){
    let file = fs::File::open(format!("{:?}/block_{}.json", &miner_configs.get_block_dir(), height_to_submit)).expect("Could not open block file");
    let file = fs::File::open("./blocks/block_1.json").expect("Could not open block file");
    let reader = BufReader::new(file);
    let block: Block = serde_json::from_reader(reader).unwrap();
    let preimage = block.preimage;
    let proof = block.data;
    (preimage, proof)
}

fn get_block_fixtures () -> (preimage: Vec<u8>, proof:  Vec<u8>){
    let tower_height = 1u64;
    let preimage = hex::decode("3a18e936c07cb5760783d450f75c257e9a80a394bff06219637da0900df3b459").unwrap();

    let proof = hex::decode("006b55ef8b3dcca6a37dd5358cace06f9a636ebf1f414177e486f39a62a27f7a45ea31cb0579a6cca00f9f6bd5fd3613a648f28b0d58563154db6ed33ff6b88ce1a3a0dc4ce2e78cecf9ba69a992aa1b4b4dabbe8a2e49ad10592f10ea5a8050a984aeaa9a61ea9724894e84d29577e261fcdd537b53937366de30df8daaa6d3570da85565286995dfa1fc73c2ddea5ae9dc3e620cbcc0b01f236f90a33b60cdab3f0b64c16987eb5e9993ebece8011e650547e9ac2a2d71e70c71a09f7826e284055ecdb227822aa282d46739929d8edbdc53ff6f555baa8834505dc77e2331c012f261c6dcd3c8c0d21ed8fc755e015fcfcfc852a142737e14030514e092ed5e005656b267a11bc3e3c1bf25c1dec218cd62dccf858957e6e9b356e713cf4904eb5272636908f65cf1603a733ae2b962fe5a01021bd26536c768f2c4abfb438ff0ed733e43410e64dfaeeb2354a3284af6d1b1e1170965d3effd2aa85faabc31003edb1cfccd5084cd733d9aa67b86dab75e9cf299c42fbdec5ffce82fc4ab8422eb3254759f133f98dfc849f182d4657f76bc83c69d1af258b52b60610a562224b9c6a152484e15597f50a503b0ba6aa604ce8b9675f237e3c2ab6988e45ca2712645cffc3fa054c292c21d73ab3b146c34353284d2c68c3f1b05351f7c551f6f0ceb666556469d81495003eb4d43fb28e772622398f41db5ddacfdefa2bd2ee500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

    (preimage, proof, tower_height)
}

fn ol_wait_for_tx (
    sender_address: AccountAddress,
    sequence_number: u64,
    client: &mut LibraClient) -> Result<(), Error>{
        // if sequence_number == 0 {
        //     println!("First transaction, cannot query.");
        //     return Ok(());
        // }

        let mut max_iterations = 10;
        println!(
            "waiting for tx from acc: {} with sequence number: {}",
            sender_address, sequence_number
        );

        loop {
            println!("test");
        //     stdout().flush().unwrap();

        //     // TODO: first transaction in sequence fails


            match &mut client
                .get_txn_by_acc_seq(sender_address, sequence_number - 1, true)
            {
                Ok(Some(txn_view)) => {
                    print!("txn_view: {:?}", txn_view);
                    if txn_view.vm_status == StatusCode::EXECUTED {
                        println!("transaction executed!");
                        if txn_view.events.is_empty() {
                            println!("no events emitted");
                        }
                        break Ok(());
                    } else {
                        // break Err(format_err!(
                        //     "transaction failed to execute; status: {:?}!",
                        //     txn_view.vm_status
                        // ));

                        break Ok(());

                    }
                }
                Err(e) => {
                    println!("Response with error: {:?}", e);
                }
                _ => {
                    print!(".");
                }
            }
            max_iterations -= 1;
        //     if max_iterations == 0 {
        //         panic!("wait_for_transaction timeout");
        //     }
            thread::sleep(time::Duration::from_millis(100));
    }
}
