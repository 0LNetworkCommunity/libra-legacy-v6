//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use std::{path::PathBuf, process::exit};
use abscissa_core::{Command, Options, Runnable};
use diem_json_rpc_types::views::TransactionView;
use ol_types::config::TxType;
use crate::{entrypoint, submit_tx::{TxError, TxParams, maybe_submit, tx_params_wrapper}};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct TeamCmd {
    #[options(short = "s", help = "set the team to be on")]
    set: bool,
    #[options(short = "c", help = "set the team to be on")]
    captain_address: AccountAddress,
}

impl Runnable for TeamCmd {    
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

        match set_wallet_type(type_int, tx_params,  entry_args.save_path) {
            Ok(_) => println!("Success: wallet type set"),
            Err(e) => {
              println!("ERROR: could not submit wallet type transaction, message: \n{:?}", &e);
              exit(1);
            }
        }
                    
    }
}

/// set the account type as slow, or community.
pub fn set_wallet_type(type_int: u8, tx_params: TxParams, save_path: Option<PathBuf>) -> Result<TransactionView, TxError>{
   maybe_submit(
      transaction_builder::encode_set_wallet_type_script_function(type_int),
      &tx_params,
      save_path,
    )
}