//! `val-set` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper},
};
use abscissa_core::{Command, Options, Runnable};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;
use ol_types::config::TxType;
use std::process::exit;

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValSetCmd {
    #[options(
        short = "j",
        help = "mark a vouchee validator as unjailed. Validators can't unjail self."
    )]
    unjail: bool,

    #[options(
        short = "a",
        help = "address of a validator vouchee which the voucher is unjailing"
    )]
    vouchee: Option<AccountAddress>,
}

impl Runnable for ValSetCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();
        let script = if let Some(addr) = *&self.vouchee {
            transaction_builder::encode_voucher_unjail_script_function(addr)
        } else {
            transaction_builder::encode_self_unjail_script_function()
        };

        match maybe_submit(
            script,
            // transaction_builder::encode_demo_e2e_script(42),
            &tx_params,
            entry_args.save_path,
        ) {
            Err(e) => {
                println!(
                    "ERROR: could not submit validator-set transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
            _ => {
                println!("SUCCESS: unjail transaction submitted");
            }
        }
    }
}
