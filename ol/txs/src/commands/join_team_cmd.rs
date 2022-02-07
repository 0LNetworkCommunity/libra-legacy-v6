//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper, TxError},
    tx_params::TxParams,
};
use abscissa_core::{Command, Options, Runnable};
use diem_json_rpc_types::views::TransactionView;
use ol_types::config::TxType;
use std::{path::PathBuf, process::exit};

use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct JoinTeamCmd {
    #[options(short = "s", help = "set the team to be on")]
    set: bool,
    #[options(short = "c", help = "the address of the team (captain)")]
    captain_address: String,
}

impl Runnable for JoinTeamCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();
        let team_address = match self.captain_address.parse::<AccountAddress>() {
            Ok(a) => a,
            Err(_) => {
                println!("could not parse --captain-address, exiting.");
                exit(1);
            }
        };
        match set_team(team_address, tx_params, entry_args.save_path) {
            Ok(_) => println!("Success: wallet type set"),
            Err(e) => {
                println!(
                    "ERROR: could not submit join team transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
        }
    }
}

/// set the account type as slow, or community.
pub fn set_team(
    captain_address: AccountAddress,
    tx_params: TxParams,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    maybe_submit(
        transaction_builder::encode_join_team_script_function(captain_address),
        &tx_params,
        save_path,
    )
}
