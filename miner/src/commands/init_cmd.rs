//! `version` subcommand

#![allow(clippy::never_loop)]

// use std::{path::PathBuf};
use crate::{config::MinerConfig, keygen};
use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use libra_genesis_tool::{init, key, keyscheme::KeyScheme};
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey
};
use libra_wallet::WalletLibrary;

/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        let (authkey, account, _) = keygen::account_from_prompt();
        initialize_miner(authkey, account).unwrap();

        // build_genesis_helper(
        //     PathBuf::from_str("/root/.0L").unwrap(),
        //     1,
        //     "OLSF".to_owned(),
        //     "experimental-genesis".to_owned(),
        //     "test".to_owned(),
        // );
        // create_node_files();

        
    }
}

pub fn initialize_miner(authkey: AuthenticationKey, account: AccountAddress) -> Result <MinerConfig, Error>{
    let miner_config = MinerConfig::init_miner_configs(authkey, account, None);
    Ok(miner_config)
}

pub fn initialize_validator(wallet: &WalletLibrary, miner_config: &MinerConfig) -> Result <(), Error>{
    let home_dir = &miner_config.workspace.node_home;
    let keys = KeyScheme::new(wallet); // TODO: Make it a reference
    let namespace = miner_config.profile.auth_key.to_owned();
    init::key_store_init(home_dir, &namespace, keys, false);

    // TODO: is this necessary?
    key::set_operator_key(home_dir, &namespace);

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

