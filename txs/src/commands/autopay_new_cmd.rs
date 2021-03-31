//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use libra_types::account_address::AccountAddress;
use ol_cli::{check::Check};
use crate::prelude::app_config;
use crate::{submit_tx::{eval_tx_status, get_tx_params, submit_tx}};
use std::{fs, path::PathBuf};
use serde::{Serialize, Deserialize};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct AutopayNewCmd {
    #[options(short = "f", help = "path of autopay_batch_file.json")]
    autopay_batch_file: PathBuf,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// Autopay payment instruction
pub struct Instruction {
    destination: AccountAddress,
    percentage: u64,
    end_epoch: u64,
    duration_epochs: Option<u64>,
}

pub fn get_instructions(autopay_batch_file: &PathBuf) -> Vec<Instruction> {
    // let cfg = app_config().clone();
    // let epoch_int = Check::new(cfg).epoch_on_chain();
    // dbg!(&epoch_int);

    let file = fs::File::open(autopay_batch_file)
        .expect(&format!("cannot open autopay batch file: {:?}", autopay_batch_file));
    let json: serde_json::Value = serde_json::from_reader(file)
        .expect("cannot parse JSON");
    let inst = json.get("instructions")
        .expect("file should have array of instructions");
    let batch = inst.as_array().unwrap().into_iter();

    batch.map(|value|{
        let inst = value.as_object().expect("expected json object");
        Instruction {
            destination: inst["destination"].as_str().unwrap().to_owned().parse().unwrap(),
            percentage: inst["percent_int"].as_u64().unwrap(),
            end_epoch: inst["end_epoch"].as_u64().unwrap(),
            duration_epochs: inst["duration_epochs"].as_u64(),
        }
    }).collect()
}


impl Runnable for AutopayNewCmd {   
    fn run(&self) {
        let tx_params = get_tx_params().unwrap();
        let instructions = get_instructions(&self.autopay_batch_file);
        
        instructions.into_iter().for_each(|i| {
            let script = transaction_builder::encode_autopay_create_instruction_script(0, i.destination, i.end_epoch, i.percentage);

            match submit_tx(
                &tx_params, 
                script,
            ) {
                Err(err) => { println!("{:?}", err) }
                Ok(res)  => {
                    eval_tx_status(res);
                }
            }
        });

    }
}