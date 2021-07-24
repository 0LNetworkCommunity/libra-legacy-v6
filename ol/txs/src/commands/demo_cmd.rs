//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use std::path::PathBuf;

use abscissa_core::{Command, Options, Runnable};
use ol_types::config::TxType;
use crate::{entrypoint, submit_tx::{TxParams, maybe_submit, tx_params_wrapper}};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct DemoCmd {}


impl Runnable for DemoCmd {    
    fn run(&self) {
        let entry_args = entrypoint::get_args();

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();
        demo_tx(
          &tx_params,
          entry_args.no_send,
          entry_args.save_path
        );
    }
}

pub fn demo_tx(tx_params: &TxParams, no_send: bool, save_path: Option<PathBuf>){
  maybe_submit(
    transaction_builder::encode_demo_e2e_script(42),
    &tx_params,
    no_send,
    save_path
  ).unwrap();
}