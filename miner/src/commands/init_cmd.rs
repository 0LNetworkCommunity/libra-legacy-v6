//! `version` subcommand

#![allow(clippy::never_loop)]

// use std::{path::PathBuf};
use crate::{application::app_config, config::MinerConfig, keygen};
use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use libra_genesis_tool::{init, key, keyscheme::KeyScheme};
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey
};
use libra_wallet::WalletLibrary;

/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    #[options(help = "Skip miner app configs")]
    skip_miner: bool,
    #[options(help = "Skip validator init")]
    skip_val: bool,
}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        let (authkey, account, wallet) = keygen::account_from_prompt();
        let mut miner_config = app_config().to_owned();
        
        if !self.skip_miner { miner_config = initialize_miner(authkey, account).unwrap() };
        if !self.skip_val { initialize_validator(&wallet, &miner_config).unwrap() };
    }
}

pub fn initialize_miner(authkey: AuthenticationKey, account: AccountAddress) -> Result <MinerConfig, Error>{
    let miner_config = MinerConfig::init_miner_configs(authkey, account, None);
    Ok(miner_config)
}

pub fn initialize_validator(wallet: &WalletLibrary, miner_config: &MinerConfig) -> Result <(), Error>{
    let home_dir = &miner_config.workspace.node_home;
    let keys = KeyScheme::new(wallet);
    let namespace = miner_config.profile.auth_key.to_owned();
    init::key_store_init(home_dir, &namespace, keys, false);
    key::set_operator_key(home_dir, &namespace);
    key::set_owner_key(home_dir, &namespace);

    println!("key file written to {}key_store.json", &miner_config.workspace.node_home)
    Ok(())
}



// pub fn _build_genesis_storage_helper(
//     output_dir: PathBuf,
//     chain_id: u8,
//     repo_owner: String,
//     repo_name: String,
//     namespace: String,
// ) -> Result <PathBuf, Error>{
//     Ok(node_files::build_genesis_from_repo(
//         output_dir,
//         chain_id,
//         repo_owner,
//         repo_name,
//         namespace
//     ))
// }
