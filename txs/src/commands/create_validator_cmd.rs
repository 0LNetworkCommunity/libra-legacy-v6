//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    prelude::app_config,
    submit_tx::{get_tx_params, maybe_submit},
};
use abscissa_core::{Command, Options, Runnable};
use libra_types::transaction::{Script, TransactionPayload};
use ol_types::{account::ValConfigs, autopay::PayInstruction};
use reqwest::Url;
use std::{
    fs::{self, File},
    io::Write,
    path::PathBuf,
};
/// `CreateAccount` subcommand
#[derive(Command, Debug, Options)]
pub struct CreateValidatorCmd {
    #[options(short = "f", help = "path of account.json")]
    account_file: Option<PathBuf>,
    #[options(short = "u", help = "onboard from URL")]
    url: Option<Url>,
}

/// create validator account by submitting transaction on chain
pub fn create_validator_script(account_json_path: &PathBuf) -> Script {
    let file_two = fs::File::open(account_json_path).expect("file should open read only");
    let account: ValConfigs =
        serde_json::from_reader(file_two).expect("file should be proper JSON");

    transaction_builder::encode_minerstate_onboarding_script(
        account.block_zero.preimage,
        account.block_zero.proof,
        account.ow_human_name.as_bytes().to_vec(),
        account.op_address.parse().unwrap(),
        account.op_auth_key_prefix,
        account.op_consensus_pubkey,
        account.op_validator_network_addresses,
        account.op_fullnode_network_addresses,
        account.op_human_name.as_bytes().to_vec(),
        // my_trusted_accounts,
        // voter_trusted_accounts,
    )
}

pub fn account_from_url(url: &Url, path: &PathBuf) -> PathBuf {
    let g_res = reqwest::blocking::get(&url.to_string());
    let g_path = path.join("account.json");
    let mut g_file = File::create(&g_path).expect("couldn't create file");
    let g_content = g_res.unwrap().bytes().unwrap().to_vec(); //.text().unwrap();
    g_file.write_all(g_content.as_slice()).unwrap();
    g_path
}

fn check_autopay(account: &ValConfigs) {
    // let signed = &account.clone().autopay_signed.unwrap();
    account
        .autopay_instructions
        .clone()
        .expect("could not find autopay instructions")
        .into_iter()
        .enumerate()
        .for_each(|(i, instr)| {
            let signed = account.autopay_signed.clone().unwrap();
            let tx = signed.iter().nth(i).unwrap();
            let payload = tx.clone().into_raw_transaction().into_payload();
            if let TransactionPayload::Script(s) = payload {
                match PayInstruction::check_instruction_safety(instr.clone(), s.clone()) {
                    Ok(_) => {}
                    Err(e) => {
                        panic!(
                            "autopay instruction does not match signed tx args, {:?}, error: {}",
                            instr, e
                        );
                    }
                }
            };
        })
}

impl Runnable for CreateValidatorCmd {
    fn run(&self) {
        let cfg = app_config();
        let entry_args = entrypoint::get_args();
        let tmp;
        if self.account_file.is_none() && self.url.is_none() {
            panic!("No account file nor URL passed in CLI")
        }
        let account_json: &PathBuf = if self.account_file.is_some() {
            self.account_file.as_ref().unwrap()
        } else {
            tmp = account_from_url(self.url.as_ref().unwrap(), &cfg.workspace.node_home).clone();
            &tmp
        };

        let tx_params = get_tx_params().unwrap();

        maybe_submit(
            create_validator_script(account_json),
            &tx_params,
            entry_args.no_send,
            entry_args.save_path,
        )
        .unwrap();
    }
}

#[test]
fn test_create_val() {
    let path = ol_fixtures::get_persona_account_json("alice").1;
    create_validator_script(&path);
}
