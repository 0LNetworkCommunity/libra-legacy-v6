//! Main entry point for MinerApp

// #![deny(warnings, missing_docs, trivial_casts, unused_qualifications)]
#![forbid(unsafe_code)]

// use txs::application::APPLICATION;

// -------- gokhan
use std::{env, process};

use txs::submit_tx::{submit_tx_, eval_tx_status};
use txs::test_tx_swarm::get_params_from_swarm;

use std::path::PathBuf;
use std::fs;

use libra_types::{transaction::{Script}};

pub fn create_user_account_script(
    account_json_path: &str // e.g. "/home/gsimsek/libra/account.json"
) -> Script {
    let file = fs::File::open(account_json_path)
        .expect("file should open read only");
    let json: serde_json::Value = serde_json::from_reader(file)
        .expect("file should be proper JSON");
    let block = json.get("block_zero")
        .expect("file should have block_zero and preimage key");

    let preimage = block
        .as_object().unwrap()
        .get("preimage").unwrap()
        .as_str().unwrap();
    
    let pre_hex = hex::decode(preimage).unwrap();

    let proof = block
        .as_object().unwrap()
        .get("proof").unwrap()
        .as_str().unwrap();
    
    let proof_hex = hex::decode(proof).unwrap();
    transaction_builder::encode_create_user_account_script(pre_hex, proof_hex)
}

pub fn demo_e2e_script() -> Script {
    // Doing a no-op transaction here which will print
    // [debug] 000000000000000011e110  in the logs if successful.
    let hello_world= 123124u64;
    transaction_builder::encode_demo_e2e_script(hello_world)
}

// ---

/// Boot MinerApp
fn main() {
    
    let args: Vec<String> = env::args().collect();

    let script = match &args[1][..] {
        "demo" => demo_e2e_script(),
        "cu"   => create_user_account_script(&args[2]),
        _      => demo_e2e_script(), // todo: "Error: stdlib script not found"
    };

    let swarm_path = PathBuf::from("./swarm_temp"); // todo: will come w/ args?
    let tx_params = get_params_from_swarm(swarm_path).unwrap();

    match submit_tx_(&tx_params, script) {
        Err(err) => { println!("{:?}", err) }
        Ok(res)  => {
            eval_tx_status(res);
        }
    }

    // abscissa_core::boot(&APPLICATION);
}
