//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use cli::libra_client::LibraClient;
use libra_types::{account_address::AccountAddress, account_state::AccountState};

use crate::submit_tx::{get_tx_params, maybe_submit, TxParams};
use dialoguer::Confirm;
use std::{convert::TryFrom, path::PathBuf};
use ol_util::autopay::get_instructions;
/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct AutopayBatchCmd {
    #[options(short = "f", help = "path of autopay_batch_file.json")]
    autopay_batch_file: PathBuf,
}

fn get_epoch(tx_params: &TxParams) -> u64 {
    let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

    let (blob, _version) = client.get_account_state_blob(AccountAddress::ZERO).unwrap();
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

                maybe_submit(script, &tx_params).unwrap();
                
            } else {
                println!("skipping instruction, going to next in batch")
            }

        });
    }
}
