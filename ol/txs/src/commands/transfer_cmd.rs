//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use crate::{entrypoint, submit_tx::{TxError, maybe_submit, tx_params_wrapper}};
use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::{account_address::AccountAddress, transaction::SignedTransaction};
use ol_types::config::TxType;
use std::{path::PathBuf, process::exit};
/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct TransferCmd {
    #[options(short = "a", help = "the new user's long address (authentication key)")]
    destination_account: String,
    #[options(short = "c", help = "the amount of coins to send to new user")]
    coins: u64,
}

impl Runnable for TransferCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let destination = match self.destination_account.parse::<AccountAddress>(){
            Ok(a) => a,
            Err(e) => {
              println!("ERROR: could not parse this account address: {}, message: {}", self.destination_account, &e.to_string());
              exit(1);
            },
        };

        match balance_transfer(destination, self.coins, entry_args.no_send, entry_args.save_path) {
            Ok(_) => println!("Success. Balance transfer success: {}", self.destination_account),
            Err(e) => {
              println!("ERROR: could not create account, message: {:?}", &e);
              exit(1);
            },
        }
    }
}

/// create an account by sending coin to it
pub fn balance_transfer(destination: AccountAddress, coins: u64, no_send: bool, save_path: Option<PathBuf>) -> Result<TransactionView, TxError>{
  let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

  // NOTE: coins here do not have the scaling factor. Rescaling is the responsibility of the Move script. See the script in ol_accounts.move for detail.
  let script = transaction_builder::encode_balance_transfer_script_function(
      destination,
      coins,
  );

  maybe_submit(script, &tx_params, no_send, save_path)
}