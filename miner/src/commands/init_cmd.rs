//! `version` subcommand

#![allow(clippy::never_loop)]

use std::{path::PathBuf, str::FromStr};

use crate::{application::app_config, config::MinerConfig, keygen};

use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use libra_genesis_tool::{init, key, keyscheme::KeyScheme, node_files};
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey
};
use libra_wallet::WalletLibrary;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        // let (authkey, account, _) = keygen::account_from_prompt();
        // initialize_miner(authkey, account);
        build_genesis(
            PathBuf::from_str("/root/.0L").unwrap(),
            1,
            "OLSF".to_owned(),
            "experimental-genesis".to_owned(),
            "test".to_owned(),
        );
    }
}

pub fn initialize_miner(authkey: AuthenticationKey, account: AccountAddress) -> Result <MinerConfig, Error>{
    let miner_config = MinerConfig::init_miner_configs(authkey, account, None);
    Ok(miner_config)
}

pub fn initialize_validator(wallet: &WalletLibrary, miner_config: &MinerConfig) -> Result <(), Error>{
    // let stored_configs = app_config();
    let home_dir = &miner_config.workspace.node_home;
    let keys = KeyScheme::new(wallet); // TODO: Make it a reference
    let namespace = "test".to_owned();
    init::key_store_init(home_dir, &namespace, keys);

    key::set_operator_key(home_dir, &namespace);

    Ok(())
}

// pub fn create_node_files() {
//     node_files::create_files(home_dir, 1, "".to_string(), "test");
//     // pub fn create_files(data_path: PathBuf, chain_id: u8, repo: String, namespace: String) -> Result<String, Error> {

// }

pub fn build_genesis(
    output_dir: PathBuf,
    chain_id: u8,
    repo_owner: String,
    repo_name: String,
    namespace: String,
) -> Result <PathBuf, Error>{
    Ok(node_files::build_genesis_from_repo(
        output_dir,
        chain_id,
        repo_owner,
        repo_name,
        namespace
    ))
}