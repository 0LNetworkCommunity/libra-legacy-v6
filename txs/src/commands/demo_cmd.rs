//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use crate::submit_tx::{get_tx_params, maybe_submit};
use libra_types::{transaction::{Script}};
use std::{fs, path::PathBuf};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct DemoCmd {}


impl Runnable for DemoCmd {    
    fn run(&self) {
        let tx_params = get_tx_params().unwrap();
        maybe_submit(transaction_builder::encode_demo_e2e_script(42), &tx_params).unwrap();
    }
}