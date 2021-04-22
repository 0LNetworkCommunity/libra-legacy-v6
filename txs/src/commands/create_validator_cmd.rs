//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use crate::{entrypoint, prelude::app_config, submit_tx::{get_tx_params, maybe_submit}};
use abscissa_core::{Command, Options, Runnable};
use libra_types::{account_address::AccountAddress, transaction::Script};
use reqwest::Url;
use std::{fs::{self, File}, io::Write, path::PathBuf};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Options)]
pub struct CreateValidatorCmd {
    #[options(short = "f", help = "path of account.json")]
    account_file: Option<PathBuf>,
    #[options(short = "u", help = "onboard from URL")]
    url: Option<Url>,
} 

pub fn create_validator_script(account_json_path: &PathBuf) -> Script {
    let file = fs::File::open(account_json_path).expect("file should open read only");
    let json: serde_json::Value =
        serde_json::from_reader(file).expect("file should be proper JSON");

    // Parse proof data
    let block = json
        .get("block_zero")
        .expect("file should have block_zero and preimage key");

    let preimage = block
        .as_object()
        .unwrap()
        .get("preimage")
        .unwrap()
        .as_str()
        .unwrap();

    let pre_hex = hex::decode(preimage).unwrap();

    let proof = block
        .as_object()
        .unwrap()
        .get("proof")
        .unwrap()
        .as_str()
        .unwrap();

    let proof_hex = hex::decode(proof).unwrap();

    // Parse validator config data
    let ow_human_name = json
        .get("ow_human_name")
        .unwrap()
        .as_str()
        .unwrap()
        .as_bytes()
        .to_vec();

    let op_address: AccountAddress = json
        .get("op_address")
        .unwrap()
        .as_str()
        .unwrap()
        .parse()
        .unwrap();

    let op_auth_key_prefix: Vec<u8> =
        hex::decode(json.get("op_auth_key_prefix").unwrap().as_str().unwrap()).unwrap();

    let op_consensus_pubkey: Vec<u8> =
        hex::decode(json.get("op_consensus_pubkey").unwrap().as_str().unwrap()).unwrap();

    let op_validator_network_addresses = hex::decode(
        json.get("op_validator_network_addresses")
            .unwrap()
            .as_str()
            .unwrap(),
    )
    .unwrap();

    let op_fullnode_network_addresses = hex::decode(
        json.get("op_fullnode_network_addresses")
            .unwrap()
            .as_str()
            .unwrap(),
    )
    .unwrap();

    let op_human_name = json
        .get("op_human_name")
        .unwrap()
        .as_str()
        .unwrap()
        .as_bytes()
        .to_vec();

    transaction_builder::encode_minerstate_onboarding_script(
        pre_hex,
        proof_hex,
        ow_human_name,
        op_address,
        op_auth_key_prefix,
        op_consensus_pubkey,
        op_validator_network_addresses,
        op_fullnode_network_addresses,
        op_human_name,
        // my_trusted_accounts,
        // voter_trusted_accounts,
    )
    // transaction_builder::encode_create_user_account_script(pre_hex, proof_hex)
}

pub fn fetch_from_web(url: &Url, path: &PathBuf) -> PathBuf {
  let g_res = reqwest::blocking::get(&url.to_string());
  let g_path = path.join("account.json");
  let mut g_file = File::create(&g_path).expect("couldn't create file");
  let g_content = g_res.unwrap().bytes().unwrap().to_vec(); //.text().unwrap();
  g_file.write_all(g_content.as_slice()).unwrap();
  g_path
}

impl Runnable for CreateValidatorCmd {
    fn run(&self) {
      let cfg = app_config();
        let entry_args = entrypoint::get_args();
        let tmp;
        if self.account_file.is_none() && self.url.is_none() {
          panic!("No account file nor URL passed in CLI")
        }
        let account_json: &PathBuf = if self.account_file.is_some(){
          self.account_file.as_ref().unwrap()
        } else {
          tmp = fetch_from_web(
            self.url.as_ref().unwrap(), 
            &cfg.workspace.node_home
          ).clone();
          &tmp
        };

        let tx_params = get_tx_params().unwrap();

        maybe_submit(
          create_validator_script(account_json),
          &tx_params,
          entry_args.no_send,
          entry_args.save_path
        ).unwrap();
    }
}
