//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use std::{path::PathBuf, process::exit};
use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use diem_types::transaction::SignedTransaction;
use ol_types::config::TxType;
use crate::{entrypoint, submit_tx::{TxParams, maybe_submit, tx_params_wrapper}};
use diem_transaction_builder::stdlib as transaction_builder;

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct WalletCmd {
    #[options(short = "c", help = "set this address as a community wallet")]
    community: bool,
    #[options(short = "s", help = "set this address as a slow wallet")]
    slow: bool,
}

impl Runnable for WalletCmd {    
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let type_int = if self.community {
          1u8
        } else if self.slow {
          0u8
        } else {
          println!("Must pass flag --community or --slow");
          exit(1);
        };

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();

        match set_wallet_type(type_int, tx_params, entry_args.no_send, entry_args.save_path) {
            Ok(_) => println!("Success: wallet type set"),
            Err(e) => {
              println!("ERROR: could not submit wallet type transaction, message: \n{:?}", &e);
              exit(1);
            }
        }
                    
    }
}

pub fn set_wallet_type(type_int: u8, tx_params: TxParams, no_send: bool, save_path: Option<PathBuf>) -> Result<SignedTransaction, Error>{
   maybe_submit(
      transaction_builder::encode_set_wallet_type_script_function(type_int),
      &tx_params,
      no_send,
      save_path,
    )
}