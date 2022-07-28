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
pub struct BurnPrefCmd {
    #[options(
        short = "c",
        help = "whenever there is a burn, send to community wallet index instead."
    )]
    community: bool,
    #[options(short = "b", help = "just burn, don't send to community wallets")]
    burn: bool,
}

impl Runnable for BurnPrefCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

        match set_burn_prefs(&tx_params, !self.burn, entry_args.save_path) {
            Ok(_) => {
                println!(
                    "Success: submitted burn preferences, community option: {}",
                    !self.burn
                );
            }
            Err(e) => {
                println!(
                    "ERROR: could not submit burn preferences transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
        }
    }
}

/// set burn prefs
pub fn set_burn_prefs(
    tx_params: &TxParams,
    burn_to_community: bool,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    let script = transaction_builder::encode_set_burn_pref_script_function(burn_to_community);

    maybe_submit(script, &tx_params, save_path)
}
