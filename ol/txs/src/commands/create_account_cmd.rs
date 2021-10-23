//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use ol_types::{config::TxType};
use crate::{entrypoint, submit_tx::{tx_params_wrapper, maybe_submit}};
use diem_types::transaction::{authenticator::AuthenticationKey};
use diem_transaction_builder::stdlib as transaction_builder;
use std::{process::exit};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]

pub struct CreateAccountCmd {
    #[options(short = "a", help = "the new user's long address (authentication key)")]
    authkey: String,
    #[options(short = "c", help = "the amount of coins to send to new user")]
    coins: u64,
}

impl Runnable for CreateAccountCmd {    
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();
        let authkey: AuthenticationKey = self.authkey.parse().unwrap();
        let account = authkey.derived_address();
        let prefix = authkey.prefix();
        // NOTE: coins here do not have the scaling factor. Rescaling is the responsibility of the Move script. See the script in ol_accounts.move for detail.
        let script = transaction_builder::encode_create_user_by_coin_tx_script_function(
          account,
          prefix.to_vec(),
          self.coins,
        );


        match maybe_submit(
            script,
            &tx_params,
            entry_args.no_send,
            entry_args.save_path,
          ) {
            Err(e) => {
                println!(
                    "ERROR: could not submit account creation transaction, message: \n{:?}", 
                    &e
                );
                exit(1);
            },
            _ => {}
          }
    }
}