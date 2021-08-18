//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use diem_transaction_builder::stdlib as transaction_builder;
use ol_types::config::TxType;
use crate::{entrypoint, submit_tx::{TxParams, maybe_submit, tx_params_wrapper}};
use std::process::exit;
use std::path::PathBuf;
use anyhow::Error;
use diem_types::transaction::SignedTransaction;
/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct DemoCmd {}

impl Runnable for DemoCmd {    
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();
        match demo_tx(
          &tx_params,
          entry_args.no_send,
          entry_args.save_path
        ) {
            Ok(r) => {
              println!("{:?}", &r);
            },
            Err(e) => {
              println!("ERROR: could not submit demo transaction, message: \n{:?}", &e);
              exit(1);
            },
        }
    }
}

/// a no-op tx to test transactions
pub fn demo_tx(
  tx_params: &TxParams, no_send: bool, save_path: Option<PathBuf>
) -> Result<SignedTransaction, Error> {
  maybe_submit(
    transaction_builder::encode_demo_e2e_script_function(42),
    &tx_params,
    no_send,
    save_path
  )
}