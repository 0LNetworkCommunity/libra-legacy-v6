//! `submit` subcommand

#![allow(clippy::never_loop)]

use super::OlMinerCmd;
use abscissa_core::{Command, Options, Runnable};
use libra_crypto::traits::ValidCryptoMaterial;
use libra_wallet::WalletLibrary;
use std::fs;
use std::io::Write;
// use crate:submit_tx::*;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {}

impl Runnable for KeygenCmd {
    /// Print version message
    fn run(&self) {
        // submit_tx::create_account();
        let mut wallet = WalletLibrary::new();

        let (auth_key, _) = wallet.new_address().expect("Could not generate address");

        let mnemonic_string = wallet.mnemonic(); //wallet.mnemonic()

        println!("OL Address:{:x}", auth_key.derived_address());
        println!("OL mnemonic: {:?}", &mnemonic_string);

        // let mut file = fs::File::create("./miner.mnemonic").unwrap();
        // file.write_all(mnemonic_string.as_bytes())
        //     .expect("Could not write mnemonic");
    }
}
