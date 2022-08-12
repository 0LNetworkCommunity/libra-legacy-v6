//! `wallet` subcommand

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

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct WalletCmd {
    #[options(short = "c", help = "set this address as a community wallet")]
    community: bool,
    #[options(short = "s", help = "set this address as a slow wallet")]
    slow: bool,
}

impl Runnable for WalletCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let type_int = if self.community {
            1u8
        } else if self.slow {
            0u8
        } else {
            println!("Must pass flag --community or --slow");
            exit(1);
        };

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap_or_else(|e| {
            println!(
                "Failed to create transaction parameters, exiting. Message: {:?}",
                e.to_string()
            );
            exit(1);
        });

        match set_wallet_type(type_int, tx_params, entry_args.save_path) {
            Ok(_) => println!("Success: wallet type set"),
            Err(e) => {
                println!(
                    "ERROR: could not submit wallet type transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
        }
    }
}

/// set the account type as slow, or community.
pub fn set_wallet_type(
    type_int: u8,
    tx_params: TxParams,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    maybe_submit(
        transaction_builder::encode_set_wallet_type_script_function(type_int),
        &tx_params,
        save_path,
    )
}
