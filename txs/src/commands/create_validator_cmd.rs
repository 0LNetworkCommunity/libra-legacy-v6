//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use crate::submit_tx::{get_tx_params, maybe_submit};
use abscissa_core::{Command, Options, Runnable};
use libra_types::{account_address::AccountAddress, transaction::Script};
use std::{fs, path::PathBuf};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateValidatorCmd {
    #[options(short = "f", help = "path of account.json")]
    account_file: PathBuf,
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

impl Runnable for CreateValidatorCmd {
    fn run(&self) {
        let account_json = &self.account_file;
        let tx_params = get_tx_params().unwrap();

        maybe_submit(create_validator_script(account_json), &tx_params);
        // match submit_tx(&tx_params, create_user_account_script(account_json)) {
        //     Err(err) => println!("{:?}", err),
        //     Ok(res) => {
        //         eval_tx_status(res);
        //     }
        // }
    }
}
