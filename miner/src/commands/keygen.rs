//! `submit` subcommand

#![allow(clippy::never_loop)]
use abscissa_core::{Command, Options, Runnable};
use libra_wallet::WalletLibrary;
use crate::config;
use toml;
use std::{
    fs,
    io::{BufReader, Write},
    path::Path,
    path::PathBuf,
};

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
        

        let mut miner_configs = config::OlMinerConfig::default();
        miner_configs.profile.auth_key = auth_key.to_string();

        let toml = toml::to_string(&miner_configs).unwrap();
        println!("Saving miner.toml with Auth Key. Update miner.toml with preferences:\n{}", toml);
        println!("==========================\n");
        
        // let mut config_path = PathBuf::from("./test_miner.toml");
        // config_path.push(format!("test_miner.toml");
        //println!("{:?}", &latest_block_path);
        let miner_config_file = "./miner.toml";
        let mut file = fs::File::create(&miner_config_file).unwrap();
        file.write(&toml.as_bytes())
            .expect("Could not write block");
        
        println!("Saved to: {}\n\
        ==========================\n\n", miner_config_file);


        println!("0L Auth Key:\n\
        You will need this in your miner.toml configs.\n\
        ---------\n\
        {:x}\n", auth_key);

        println!("0L Address:\n\
        This address is derived from your Auth Key, it has not yet been created on chain. You'll need to submit a genesis miner proof for that.\n\
        ---------\n\
        {:x}\n", auth_key.derived_address());

        println!("0L mnemonic:\n\
        Please don't lose this. WRITE THIS DOWN NOW. Nobody can help you if you lose it.\n\
        ---------\n\
        {}\n", &mnemonic_string.as_str());
    }
}
