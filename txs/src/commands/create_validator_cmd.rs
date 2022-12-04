//! `create-validator` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    prelude::app_config,
    relay,
    submit_tx::{maybe_submit, tx_params_wrapper},
};
use abscissa_core::{Command, Options, Runnable};
use anyhow::{bail, Error};
use diem_json_rpc_types::views::VMStatusView;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::transaction::TransactionPayload;
use ol_types::{account::ValConfigs, config::TxType};
use reqwest::Url;
use std::{
    fs::{self, File},
    io::Write,
    path::PathBuf,
    process::exit,
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
pub fn create_validator_script_function(
    new_account: &ValConfigs,
) -> Result<TransactionPayload, Error> {
    let new_account = new_account.to_owned();

    let block = match new_account.block_zero {
        Some(b) => b,
        None => bail!("no block zero found in account.json"),
    };
    Ok(transaction_builder::encode_create_acc_val_script_function(
        block.preimage.clone(),
        block.proof.clone(),
        block.difficulty(),
        block.security(),
        new_account.ow_human_name.to_string().as_bytes().to_vec(),
        new_account.op_address.parse().unwrap(),
        new_account.op_auth_key_prefix,
        new_account.op_consensus_pubkey,
        new_account.op_validator_network_addresses,
        new_account.op_fullnode_network_addresses,
        new_account.op_human_name.as_bytes().to_vec(),
        // my_trusted_accounts,
        // voter_trusted_accounts,
    ))
}

pub fn account_from_url(url: &mut Url, path: &PathBuf) -> PathBuf {
    url.set_port(Some(3030)).unwrap();
    let url_string = url.join("account.json").unwrap();
    let res = reqwest::blocking::get(url_string);

    let host_string = url.host().unwrap().to_string();
    let file_path = path.join(format!("{}.account.json", host_string));
    let mut file = File::create(&file_path).expect("couldn't create file");
    let content = res.unwrap().bytes().unwrap().to_vec(); //.text().unwrap();
    file.write_all(content.as_slice()).unwrap();
    file_path
}

impl Runnable for CreateValidatorCmd {
    fn run(&self) {
        let cfg = app_config().clone();
        let entry_args = entrypoint::get_args();
        let tmp;
        if self.account_file.is_none() && self.url.is_none() {
            println!("No account file nor URL passed in CLI");
            exit(1);
        }
        let account_json_path: &PathBuf = if self.account_file.is_some() {
            self.account_file.as_ref().unwrap()
        } else {
            let mut url = self.url.clone().unwrap();
            tmp = account_from_url(&mut url, &cfg.workspace.node_home).clone();
            &tmp
        };

        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

        let file = fs::File::open(account_json_path).expect("file should open read only");
        let new_account: ValConfigs =
            serde_json::from_reader(file).expect("file should be proper JSON");

        println!("Sending account creation transaction");
        match maybe_submit(
            create_validator_script_function(&new_account)
                .expect("could not create validator onboarding script"),
            &tx_params,
            entry_args.save_path,
        ) {
            Ok(_) => {
                println!("Account created on chain.");
            }
            Err(e) => {
                println!("ERROR: creating account fails with:");
                if let Some(view) = e.tx_view {
                    match &view.vm_status {
                        // diem_json_rpc_types::views::VMStatusView::Executed => todo!(),
                        VMStatusView::OutOfGas => {
                            println!(
                                "looks like you're out of gas, message: {:?}",
                                &view.vm_status
                            );
                        }
                        VMStatusView::MoveAbort {
                            location,
                            abort_code,
                            explanation: _,
                        } => {
                            if location.contains("AccountScripts") && abort_code == &0 {
                                println!("This account already exists on chain");
                            } else {
                                println!("transaction error, message: {:?}", &view.vm_status);
                            }
                        }
                        _ => println!("transaction error, message: {:?}", &view.vm_status),
                    }
                }
            }
        }
        // submit initial autopay if there are any
        match new_account.check_autopay() {
            Ok(_) => {
                println!(
                    "\nRelaying previously signed transactions from: {:?}\n",
                    &new_account.ow_human_name
                );
                match relay::relay_batch(&new_account.autopay_signed.unwrap(), &tx_params) {
                    Ok(_) => {
                        println!("\nUser transactions successfully relayed\n")
                    }
                    Err(e) => {
                        println!("\nError relaying transactions. Message: {:?}", e);
                        exit(1);
                    }
                }
            }
            Err(e) => {
                println!("\nNo autopay txs to send. Message: {:?}", e);
            }
        }
        println!("Success");
    }
}
