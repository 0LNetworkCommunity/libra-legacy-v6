//! `autopay` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper},
};
use abscissa_core::{Command, Options, Runnable};
use diem_transaction_builder::stdlib as transaction_builder;
use ol_types::config::TxType;
use std::process::exit;

/// command to enable or disable autopay
#[derive(Command, Debug, Default, Options)]
pub struct AutopayCmd {
    #[options(help = "enable autopay on account")]
    enable: bool,
    #[options(help = "disable autopay on account")]
    disable: bool,
}

impl Runnable for AutopayCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();
        let script = if *&self.enable {
            transaction_builder::encode_autopay_enable_script_function()
        } else if *&self.disable {
            transaction_builder::encode_autopay_disable_script_function()
        } else {
            panic!("must choose --enable or --disable");
        };

        match maybe_submit(script, &tx_params, entry_args.save_path) {
            Err(e) => {
                println!(
                    "ERROR: could not submit autopay enable transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
            _ => {}
        }
    }
}
