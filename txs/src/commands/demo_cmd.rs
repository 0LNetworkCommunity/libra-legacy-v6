//! `demo` subcommand

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
use std::path::PathBuf;
use std::process::exit;

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct DemoCmd {}

impl Runnable for DemoCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();

        match demo_tx(&tx_params, entry_args.save_path) {
            Ok(r) => {
                println!("{:?}", &r);
            }
            Err(e) => {
                println!(
                    "ERROR: could not submit demo transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
        }
    }
}

/// a no-op tx to test transactions
pub fn demo_tx(
    tx_params: &TxParams,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    let script = transaction_builder::encode_demo_e2e_script_function(42);

    maybe_submit(script, &tx_params, save_path)
}
