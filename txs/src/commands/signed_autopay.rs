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