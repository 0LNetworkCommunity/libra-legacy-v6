//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper, TxError},
    tx_params::TxParams,
};
use abscissa_core::{Command, Options, Runnable};
use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use ol_types::config::TxType;
use std::{path::PathBuf, process::exit};

/// `CreateAccount`subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateTeamCmd {
    #[options(short = "n", help = "name of the team")]
    team_name: String,
    #[options(short = "p", help = "percent operator reward")]
    operator_pct_reward: u64,
}

impl Runnable for CreateTeamCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();

        match create_team(
            &self.team_name,
            &self.operator_pct_reward,
            tx_params,
            entry_args.save_path,
        ) {
            Ok(_) => println!("Success: wallet type set"),
            Err(e) => {
                println!("ERROR: could not create team, message: \n{:?}", &e);
                exit(1);
            }
        }
    }
}

/// set the account type as slow, or community.
pub fn create_team(
    team_name: &str,
    percent: &u64,
    tx_params: TxParams,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    maybe_submit(
        transaction_builder::encode_create_team_script_function(
            team_name.as_bytes().to_vec(),
            *percent,
        ),
        &tx_params,
        save_path,
    )
}
