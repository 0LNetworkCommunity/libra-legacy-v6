//! `authkey` subcommand

#![allow(clippy::never_loop)]

use std::process::exit;

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper},
};
use abscissa_core::{Command, Options, Runnable};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::transaction::authenticator::AuthenticationKey;
use ol_types::config::TxType;

#[derive(Command, Debug, Default, Options)]
pub struct AuthkeyCmd {
    #[options(help = "the authkey to rotate to")]
    new_key: Option<AuthenticationKey>,
}

impl Runnable for AuthkeyCmd {
    fn run(&self) {
        if let Some(key) = &self.new_key {
            let entry_args = entrypoint::get_args();
            let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();

            use transaction_builder::encode_rotate_authentication_key_script_function;
            let payload = encode_rotate_authentication_key_script_function(key.to_vec());
            maybe_submit(payload, &tx_params, entry_args.save_path).unwrap();
        } else {
            println!("ERROR: expected --authkey to set new account authorization key");
            exit(1);
        };
    }
}
