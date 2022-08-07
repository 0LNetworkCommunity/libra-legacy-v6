//! `demo` subcommand

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
pub struct VouchCmd {
    #[options(short = "a", help = "set this address as part of your trusted set.")]
    address: Option<String>,

    #[options(short = "r", help = "set this address as part of your trusted set.")]
    revoke: bool,
    #[options(
        short = "e",
        help = "enable the vouch struct on your account in case it hasn't on account creation."
    )]
    enable: bool,
}

impl Runnable for VouchCmd {
    fn run(&self) {
        let _entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

        let script = if self.address.is_some() {
            if let Some(addr) = &self.address {
                match addr.parse::<AccountAddress>() {
                    Ok(a) => {
                        if self.revoke {
                            transaction_builder::encode_revoke_vouch_script_function(a)
                        } else {
                            transaction_builder::encode_vouch_for_script_function(a)
                        }
                    }
                    Err(_) => {
                        println!("could not parse address from args");
                        exit(1)
                    }
                }
            } else {
                println!("no arguments passed. Did you mean to `vouch --address <address>`");
                exit(1)
            }
        } else if self.enable {
            transaction_builder::encode_init_vouch_script_function()
        } else {
            println!("no arguments passed. Did you mean to `vouch --address <address>`");
            exit(1);
        };

        match maybe_submit(script, &tx_params, None) {
            Ok(r) => {
                println!("{:?}", &r);
            }
            Err(e) => {
                println!(
                    "ERROR: could not submit vouch transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
        }
    }
}
