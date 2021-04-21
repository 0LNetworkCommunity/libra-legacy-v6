//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use libra_types::transaction::{Script, SignedTransaction};

use crate::{entrypoint, sign_tx::sign_tx, submit_tx::{get_tx_params, batch_wrapper, TxParams}};
use dialoguer::Confirm;
use std::path::PathBuf;
use ol_util::autopay::{Instruction, get_instructions};
/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct AutopayBatchCmd {
    #[options(short = "f", help = "path of autopay_batch_file.json")]
    autopay_batch_file: PathBuf,
}

// fn get_epoch(tx_params: &TxParams) -> u64 {
//     let mut client = LibraClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();

//     let (blob, _version) = client.get_account_state_blob(AccountAddress::ZERO).unwrap();
//     if let Some(account_blob) = blob {
//         let account_state = AccountState::try_from(&account_blob).unwrap();
//         return account_state
//             .get_configuration_resource()
//             .unwrap()
//             .unwrap()
//             .epoch();
//     }
//     0
// }

impl Runnable for AutopayBatchCmd {
    fn run(&self) {
        // Note: autopay batching needs to have id numbers to each instruction.
        // will not increment automatically, since this can lead to user error.
        let entry_args = entrypoint::get_args();

        let tx_params = get_tx_params().unwrap();

        let epoch = crate::epoch::get_epoch(&tx_params);
        println!("The current epoch is: {}", epoch);
        let instructions = get_instructions(&self.autopay_batch_file);
        let scripts = process_instructions(instructions, epoch);
        batch_wrapper(scripts, &tx_params, entry_args.no_send, entry_args.save_path)

    }
}

/// Process autopay instructions in to scripts
pub fn process_instructions(instructions: Vec<Instruction>, current_epoch: u64) -> Vec<Script> {
        // TODO: Check instruction IDs are sequential.
        instructions.into_iter().filter_map(|i| {
            let warning = format!(
                "Instruction {uid}:\nSend {percent_balance:?}% of your total balance every epoch {duration_epochs} times (until epoch {epoch_ending}) to address: {destination}?",
                uid = &i.uid,
                percent_balance = &i.percent_balance,
                duration_epochs = &i.duration_epochs.unwrap(),
                epoch_ending = &i.duration_epochs.unwrap() + current_epoch,
                destination = &i.destination,
            );
            println!("{}", &warning);            // check the user wants to do this.
            match Confirm::new().with_prompt("").interact().unwrap() {
              true => Some(i),
              _ =>  {
                println!("skipping instruction, going to next in batch");
                None
              }
            }            
        })
        // .collect()
        .map(|i| {
          transaction_builder::encode_autopay_create_instruction_script(i.uid, i.destination, i.end_epoch, i.percent_balance.unwrap())
        })
        .collect()
}
 
/// return a vec of signed transactions
pub fn sign_instructions(scripts: Vec<Script>, starting_sequence_num: u64, tx_params: &TxParams) -> Vec<SignedTransaction>{
  scripts.into_iter()
  .enumerate()
  .map(|(i, s)| {
    let seq = i as u64 + starting_sequence_num;
    sign_tx(&s, tx_params, seq, tx_params.chain_id).unwrap()
    })
  .collect()
}
