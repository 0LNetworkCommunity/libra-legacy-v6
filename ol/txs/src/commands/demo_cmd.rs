//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use diem_transaction_builder::stdlib as transaction_builder;
use ol_types::config::TxType;
use crate::{entrypoint, submit_tx::{tx_params_wrapper, maybe_submit}};
use std::process::exit;

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct DemoCmd {}


impl Runnable for DemoCmd {    
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();
        match maybe_submit(
          transaction_builder::encode_demo_e2e_script_function(42),
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