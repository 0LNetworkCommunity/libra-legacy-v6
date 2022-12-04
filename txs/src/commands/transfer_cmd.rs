//! `transfer` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper, TxError},
    tx_params::TxParams,
};
use abscissa_core::{Command, Options, Runnable};

use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;
use ol_types::config::TxType;
use std::{path::PathBuf, process::exit};
/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct TransferCmd {
    #[options(short = "a", help = "the new user's address")]
    destination_account: String,
    #[options(short = "c", help = "the amount of coins to send to new user")]
    coins: u64,
}

impl Runnable for TransferCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let destination = match self.destination_account.parse::<AccountAddress>() {
            Ok(a) => a,
            Err(e) => {
                println!(
                    "ERROR: could not parse this account address: {}, message: {}",
                    self.destination_account,
                    &e.to_string()
                );
                exit(1);
            }
        };
        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();
        match balance_transfer(destination, self.coins, tx_params, entry_args.save_path) {
            Ok(_) => println!(
                "Success: Balance transfer posted: {}",
                self.destination_account
            ),
            Err(e) => {
                println!("ERROR: execute balance transfer message: {:?}", &e);
                exit(1);
            }
        }
    }
}

/// create an account by sending coin to it
pub fn balance_transfer(
    destination: AccountAddress,
    coins: u64,
    tx_params: TxParams,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    // NOTE: coins here do not have the scaling factor. Rescaling is the responsibility of the Move script. See the script in ol_accounts.move for detail.
    let script = transaction_builder::encode_balance_transfer_script_function(destination, coins);

    maybe_submit(script, &tx_params, save_path)
}
