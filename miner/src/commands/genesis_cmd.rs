//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{application::app_config, config::MinerConfig};
use abscissa_core::{Command, Options, Runnable};
use libra_genesis_tool::node_files;

/// `genesis` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct GenesisCmd {
    #[options(help = "id of the chain")]
    chain_id: u8,
    #[options(help = "github org of genesis repo")]
    github_org: String,
    #[options(help = "repo with with genesis transactions")]
    repo: String,   
}


impl Runnable for GenesisCmd {
    /// Print version message
    fn run(&self) {
        let miner_configs = app_config();
        
        create_node_files(
            &miner_configs.clone(),
            self.chain_id,
            &self.github_org,
            &self.repo,
        )
        
    }
}

pub fn create_node_files(
    miner_config: &MinerConfig,
    chain_id: u8,
    github_org: &str,
    repo: &str,
) {
    let home_dir = miner_config.workspace.node_home.to_owned();
    let namespace = miner_config.profile.auth_key.as_str();
    node_files::create_files(
        home_dir, 
        chain_id,
        github_org,
        repo,
        namespace
    ).unwrap();
}

// pub fn experimental_defaults() {
//     let miner_configs = app_config();
//     create_node_files(
//         miner_configs.clone(),
//         1,
//         "OLSF".to_string(),
//         "experimental-genesis".to_string(),
//     );
// }
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

