//! `autopay-batch` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    prelude::app_config,
    sign_tx::sign_tx,
    submit_tx::{batch_wrapper, tx_params_wrapper},
    tx_params::TxParams,
};
use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use dialoguer::Confirm;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;
use diem_types::transaction::{SignedTransaction, TransactionPayload};
use ol::node::node::Node;
use ol_types::{
    autopay::AutoPayResource,
    config::{TxType, IS_TEST},
    pay_instruction::PayInstruction,
};
use std::{path::PathBuf, process::exit};

/// command to submit a batch of autopay tx from file
#[derive(Command, Debug, Default, Options)]
pub struct AutopayBatchCmd {
    #[options(short = "f", help = "path of autopay_batch_file.json")]
    autopay_batch_file: PathBuf,
}

impl Runnable for AutopayBatchCmd {
    fn run(&self) {
        // Note: autopay batching needs to have id numbers to each instruction.
        // will not increment automatically, since this can lead to user error.
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();
        let cfg = app_config();

        // // get highest autopay number
        let mut node = Node::default_from_cfg(cfg.clone(), entry_args.swarm_path);
        let start_id = match get_autopay_start_id(&mut node, tx_params.owner_address) {
            Ok(i) => Some(i),
            Err(e) => {
                println!(
                    "ERROR: Could not fetch AutoPay ids, cannot continue to send tx. Message: {:?}",
                    e
                );
                exit(1);
            }
        };
        println!("Latest Autopay id: {:?}", &start_id);
        node.refresh_chain_info().unwrap();
        let epoch = node.vitals.chain_view.unwrap().epoch;
        println!("The current epoch is: {}\n", epoch);

        println!(
          "Next you will confirm the instructions before sending the batch transaction\n ALL INSTRUCTIONS MUST BE CONFIRMED before the tx submission happens. Batches are atomic. If you reject one transaction, no batch will be submitted, and you must revise the batch.json file"
        );

        let instructions = PayInstruction::parse_autopay_instructions(
            &self.autopay_batch_file,
            Some(epoch),
            start_id,
        )
        .unwrap();
        let scripts = process_instructions(instructions);
        match batch_wrapper(
            scripts,
            &tx_params,
            entry_args.no_send,
            entry_args.save_path,
        ) {
            Ok(_) => {}
            Err(e) => println!("ERROR: could not batch transactions, message: {:?}", e),
        }
    }
}

/// Process autopay instructions into scripts
pub fn process_instructions(instructions: Vec<PayInstruction>) -> Vec<TransactionPayload> {
    // TODO: Check instruction IDs are sequential.
    instructions.into_iter().filter_map(|i| {
    // double check transactions
      match i.type_move.unwrap()<= 3 {
          true => {},
          false => {
            println!("Instruction type not valid for transactions: {:?}", &i);
            exit(1);
          },
      }

      if i.duration_epochs.is_some() && i.duration_epochs.unwrap() < 1 {
        println!("Instructions must have epoch_duration greater than 0. Exiting. Instruction: {:?}", &i);
        exit(1);
      }

      if i.end_epoch.is_none() || i.end_epoch.unwrap() < 1 {
        println!("Instructions must have end_epoch greater than 0. Exiting. Instruction: {:?}", &i);
        exit(1);
      }

      println!("{}", i.text_instruction());
      // accept if CI mode.
      if *IS_TEST { return Some(i) }

      // check the user wants to do this.
      match Confirm::new().with_prompt("").interact().unwrap() {
        true => Some(i),
        _ =>  {
          panic!("Autopay configuration aborted. Check batch configuration file or template");
        }
      }
  })
  .map(|i| {
    transaction_builder::encode_autopay_create_instruction_script_function(
      i.uid.unwrap(),
      i.type_move.unwrap(),
      i.destination,
      i.end_epoch.unwrap(),
      i.value_move.unwrap()
    )
  })
  .collect()
}

/// return a vec of signed transactions
pub fn sign_instructions(
    scripts: Vec<TransactionPayload>,
    starting_sequence_num: u64,
    tx_params: &TxParams,
) -> Vec<SignedTransaction> {
    scripts
        .into_iter()
        .enumerate()
        .map(|(i, s)| {
            let seq = i as u64 + starting_sequence_num;
            sign_tx(s, tx_params, seq, tx_params.chain_id).unwrap()
        })
        .collect()
}

#[test]
fn test_instruction_script_match() {
    use diem_types::account_address::AccountAddress;
    use ol_types::pay_instruction::InstructionType;
    if let TransactionPayload::Script(s) =
        transaction_builder::encode_autopay_create_instruction_script_function(
            1,
            0,
            AccountAddress::ZERO,
            10,
            1000,
        )
    {
        let instr = PayInstruction {
            uid: Some(1),
            type_of: InstructionType::PercentOfBalance,
            destination: AccountAddress::ZERO,
            end_epoch: Some(10),
            duration_epochs: None,
            note: Some("test".to_owned()),
            type_move: Some(0),
            value: 10f64,
            value_move: Some(1000u64),
        };

        instr.check_instruction_match_tx(s).unwrap();
    }
}

fn get_autopay_start_id(node: &mut Node, account: AccountAddress) -> Result<u64, Error> {
    let s = node.get_account_state(account)?;
    match s
        .get_resource_impl::<AutoPayResource>(AutoPayResource::resource_path().as_slice())
        .unwrap()
    {
        Some(a) => {
            let mut ids = vec![0u64];
            a.payment.iter().for_each(|i| {
                ids.push(i.uid);
            });
            ids.sort();
            Ok(ids.pop().unwrap())
        }
        None => Ok(0),
    }
}
