//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use cli::libra_client::LibraClient;
use libra_types::{account_address::AccountAddress, account_state::AccountState};

use crate::{submit_tx::{TxParams, eval_tx_status, get_tx_params, submit_tx}};
use std::{convert::TryFrom, fs, path::PathBuf};
use serde::{Serialize, Deserialize};
use dialoguer::Confirm;
/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct AutopayBatchCmd {
    #[options(short = "f", help = "path of autopay_batch_file.json")]
    autopay_batch_file: PathBuf,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// Autopay payment instruction
pub struct Instruction {
    uid: u64,
    destination: AccountAddress,
    percentage: u64,
    end_epoch: u64,
    duration_epochs: Option<u64>,
}

pub fn get_instructions(autopay_batch_file: &PathBuf) -> Vec<Instruction> {
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
            uid: inst["uid"].as_u64().unwrap(),
            destination: inst["destination"].as_str().unwrap().to_owned().parse().unwrap(),
            percentage: inst["percent_int"].as_u64().unwrap(),
            end_epoch: inst["end_epoch"].as_u64().unwrap(),
            duration_epochs: inst["duration_epochs"].as_u64(),
        }
    }).collect()
}

fn get_epoch(tx_params: &TxParams) -> u64 {
    let mut client = LibraClient::new(
        tx_params.url.clone(), tx_params.waypoint
    ).unwrap();

    let (blob, _version) = client
    .get_account_state_blob(AccountAddress::ZERO)
    .unwrap();
    if let Some(account_blob) = blob {
        let account_state = AccountState::try_from(&account_blob).unwrap();
        return account_state
                .get_configuration_resource()
                .unwrap()
                .unwrap()
                .epoch();
    }
    0
}

fn send_autopay_enable(tx_params: &TxParams) {
    let script = transaction_builder::encode_autopay_enable_script();

    match submit_tx(
        &tx_params, 
        script,
    ) {
        Err(err) => { println!("{:?}", err) }
        Ok(res)  => {
            eval_tx_status(res);
        }
    }
}

impl Runnable for AutopayBatchCmd {   
    fn run(&self) {
        // Note: autopay batching needs to have id numbers to each instruction.
        // will not increment automatically, since this can lead to user error.

        let tx_params = get_tx_params().unwrap();

        let epoch = get_epoch(&tx_params);
        println!("The current epoch is: {}", epoch);

        // TODO: Check instruction IDs are sequential.
        
        let instructions = get_instructions(&self.autopay_batch_file);
        instructions.into_iter().for_each(|i| {
            let warning = format!(
                "Instruction {uid}:\nSend {percentage}% of your balance every epoch {duration_epochs} times (until epoch {epoch_ending}) to address: {destination}?",
                uid = &i.uid,
                percentage = &i.percentage,
                duration_epochs = &i.duration_epochs.unwrap(),
                epoch_ending = &i.duration_epochs.unwrap() + epoch,
                destination = &i.destination,
            );

            println!("{}", &warning);
            // check the user wants to do this.
            if Confirm::new().with_prompt("").interact().unwrap() {
                let script = transaction_builder::encode_autopay_create_instruction_script(i.uid, i.destination, i.end_epoch, i.percentage);

                match submit_tx(
                    &tx_params, 
                    script,
                ) {
                    Err(err) => { println!("{:?}", err) }
                    Ok(res)  => {
                        eval_tx_status(res);
                    }
                }
            } else {
                println!("skipping instruction, going to next in batch")
            }

        });

    }
}