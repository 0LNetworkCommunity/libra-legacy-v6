//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable, status_err};
use crate::{
    prelude::app_config, 
    submit_tx::{submit_tx, get_tx_params, eval_tx_status}
};
use std::path::PathBuf;
use std::fs;
use libra_types::{transaction::{Script}, waypoint::Waypoint};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateAccountCmd {
    #[options(help = "path of account.json")]
    account_json_path: PathBuf,
    #[options(help = "url to send txs")]
    url: Option<String>,
    #[options(help = "waypoint to connect to")]
    waypoint: Option<String>,
    #[options(help = "temp swarm path, using transaction params from swarm")]
    swarm_path: Option<PathBuf>,
}

pub fn create_user_account_script(
    account_json_path: &str // e.g. "~/account.json"
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

impl Runnable for CreateAccountCmd {    

    fn run(&self) {
        let account_json = self.account_json_path.to_str().unwrap();
        let tx_params = get_tx_params(
            &self.url, &self.waypoint, &self.swarm_path
        ).unwrap();

        match submit_tx(
            &tx_params, 
            create_user_account_script(account_json)
        ) {
            Err(err) => { println!("{:?}", err) }
            Ok(res)  => {
                eval_tx_status(res);
            }
        }
    }
}