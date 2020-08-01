//! `submit` subcommand

#![allow(clippy::never_loop)]


use abscissa_core::{Command, Options, Runnable};

use libra_wallet::WalletLibrary;


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

        println!("0L Auth Key:\nYou will need this in your miner.toml configs.\n---------\n{:x}\n", auth_key);
        println!("0L Address:\nThis address is derived from your Auth Key, it has not yet been created onchain. You'll need to submit a genesis miner proof for that.\n---------\n{:x}\n", auth_key.derived_address());
        println!("0L mnemonic:\nPlease don't lose this. It's not saved anywhere on disk\n---------\n{}\n", &mnemonic_string.as_str());
    }
}
