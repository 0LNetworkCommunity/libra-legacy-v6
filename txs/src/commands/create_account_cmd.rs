//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable, status_err};
use crate::{prelude::app_config, submit_tx::{
        submit_tx,
        get_params_from_swarm,
        get_params_from_toml,
        get_params_from_command_line,
        eval_tx_status,
    }};
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
        // TODO(GS): generalize to main.rs for all commands

        // Get tx_params from toml e.g. ~/.0L/txs.toml, or use Profile::default()
        let miner_config = app_config();
        let mut tx_params= get_params_from_toml(miner_config.clone()).unwrap();

        // If the settings are not initialized in txs.toml
        if miner_config.profile.auth_key == "" { 
            // Get tx_params from local swarm
            tx_params = if self.swarm_path.clone().is_some() {
                get_params_from_swarm(
                    self.swarm_path.clone().expect("needs a valid swarm temp dir")
                ).unwrap()
            } else { // Get tx_params from command line
                if *&self.url.is_none() | *&self.waypoint.is_none() {
                    status_err!("Need to pass url and waypoint");
                    return
                }                
                get_params_from_command_line(
                    &self.url.clone().expect("need to pass a url string http://a.b.c.d"),
                    &self.waypoint.clone().expect("need to pass a waypoint in command line")
                ).unwrap()
            };
        }

        // Override waypoint if swarm is not used
        if self.swarm_path.is_none() {
            tx_params.waypoint = match miner_config.get_waypoint() {
                Some(waypoint) => waypoint, // e.g. from ~/.0L/key_store.json
                _ => {
                    if *&self.waypoint.is_some() { // from command line
                        self.waypoint.clone().unwrap().parse::<Waypoint>().unwrap()
                    } else { // from toml or Profile::default()
                        miner_config.profile.waypoint 
                    }
                }
            };
        }


        let account_json = self.account_json_path.to_str().unwrap();
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