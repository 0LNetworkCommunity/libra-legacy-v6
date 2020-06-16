//! `keygen` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use libra_crypto::traits::ValidCryptoMaterial;
use libra_wallet::WalletLibrary;

/// `keygen` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeyGenCmd {}

impl Runnable for KeyGenCmd {
    /// Generate a keypair to the terminal
    fn run(&self) {
        let mut wallet = WalletLibrary::new();

        let (auth_key, _) = wallet.new_address().expect("Could not generate address");

        let hex_key = hex::encode(auth_key.to_bytes());

        println!("OL key:{}", hex_key);
        println!("OL mnemonic: {}", wallet.mnemonic());
    }
}
