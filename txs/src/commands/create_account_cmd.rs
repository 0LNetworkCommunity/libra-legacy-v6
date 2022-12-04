//! `create-account` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper, TxError},
    tx_params::TxParams,
};
use abscissa_core::{Command, Options, Runnable};

use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::transaction::authenticator::AuthenticationKey;
use ol_types::config::TxType;
use std::{path::PathBuf, process::exit};
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
        let authkey = match self.authkey.parse::<AuthenticationKey>() {
            Ok(a) => a,
            Err(e) => {
                println!(
                    "ERROR: could not parse this account address: {}, message: {}",
                    self.authkey,
                    &e.to_string()
                );
                exit(1);
            }
        };
        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

        match create_from_auth_and_coin(authkey, self.coins, tx_params, entry_args.save_path) {
            Ok(_) => println!("Success: Account created for authkey: {}", authkey),
            Err(e) => {
                println!("ERROR: could not create account, message: {:?}", &e);
                exit(1);
            }
        }
    }
}

/// create an account by sending coin to it
pub fn create_from_auth_and_coin(
    authkey: AuthenticationKey,
    coins: u64,
    tx_params: TxParams,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    let account = authkey.derived_address();
    let prefix = authkey.prefix();
    // NOTE: coins here do not have the scaling factor. Rescaling is the responsibility of the Move script. See the script in ol_accounts.move for detail.
    let script = transaction_builder::encode_create_user_by_coin_tx_script_function(
        account,
        prefix.to_vec(),
        coins,
    );

    maybe_submit(script, &tx_params, save_path)
}
