//! `version` subcommand

#![allow(clippy::never_loop)]

use std::{path::PathBuf};

use crate::{application::app_config, config::MinerConfig};

use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
// use libra_config::config::{GitHubConfig, Token};
use libra_genesis_tool::{init, key, keyscheme::KeyScheme, node_files};
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey
};
// use libra_management::{
//     config::ConfigPath,
//     secure_backend::{SecureBackend, SharedBackend}

// };


use libra_wallet::WalletLibrary;

/// `genesis` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        let miner_configs = app_config();
        create_node_files(miner_configs.clone())
        
    }
}

pub fn create_node_files(miner_config: MinerConfig) {
    let home_dir = miner_config.workspace.node_home;

    node_files::create_files(
        home_dir, 
        1,
        "OLSF".to_string(),
        "experimental-genesis".to_string(),
        miner_config.profile.auth_key.to_string()
    ).unwrap();
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

// pub fn build_genesis(){
//     let path = PathBuf::from_str("~/.0L/").unwrap();

//     let config = ConfigPath {
//         config: Some(path)
//     };
//     let chain_id = 1;

//     let secure = SecureBackend::GitHub(GitHubConfig {
//         repository_owner: "test".to_owned(),
//         repository: "test".to_owned(),
//         token: Token::FromDisk(path.join("github_token.txt")),
//         namespace: None
//     });

//     let shared_backend = SharedBackend {
//         shared_backend: Some(secure)
//     };
    
//     node_files::build_genesis(
//         config,
//         chain_id,
//         shared_backend,
//         path
//     );
    
// }

