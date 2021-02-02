//! `version` subcommand

#![allow(clippy::never_loop)]

use std::{fs::File, path::{PathBuf}};

use crate::{application::app_config, config::MinerConfig};
use abscissa_core::{Command, Options, Runnable};
use libra_genesis_tool::node_files;
use std::io::Write;
/// `genesis` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct GenesisCmd {
    #[options(help = "id of the chain")]
    chain_id: Option<u8>,
    #[options(help = "github org of genesis repo")]
    github_org: Option<String>,
    #[options(help = "repo with with genesis transactions")]
    repo: Option<String>,   
}


impl Runnable for GenesisCmd {
    /// Print version message
    fn run(&self) {
        let miner_configs = app_config();
        genesis_files(
            &miner_configs.clone(),
            &self.chain_id,
            &self.github_org,
            &self.repo,
        ) 
    }
}

pub fn genesis_files(
    miner_config: &MinerConfig,
    chain_id: &Option<u8>,
    github_org: &Option<String>,
    repo: &Option<String>,
) {
    let home_dir = miner_config.workspace.node_home.to_owned();
    // 0L convention is for the namespace of the operator to be appended by '-oper'
    let namespace = miner_config.profile.auth_key.clone() + "-oper";
    
    node_files::create_files(
        home_dir.clone(), 
        chain_id.unwrap_or(1),
        &github_org.clone().unwrap_or("OLSF".to_string()),
        &repo.clone().unwrap_or("experimetal-genesis".to_string()),
        &namespace,
        if repo.is_some() {true} else {false},
    ).unwrap();

    println!("validator configurations initialized, file saved to: {:?}", &home_dir.join("node.yaml"));

}

pub fn get_files(home_dir: PathBuf) {
    let w_res = reqwest::blocking::get("https://raw.githubusercontent.com/OLSF/genesis-archive/main/genesis/genesis_waypoint");

    let w_path = &home_dir.join("genesis_waypoint");
    let mut w_file = File::create(&w_path).expect("couldn't create file");
    let w_content =  w_res.unwrap().text().unwrap();
    w_file.write_all(w_content.as_bytes()).unwrap();

    let g_res = reqwest::blocking::get("https://raw.githubusercontent.com/OLSF/genesis-archive/main/genesis/genesis.blob");

    let g_path = &home_dir.join("genesis.blob");
    let mut g_file = File::create(&g_path).expect("couldn't create file");
    let g_content =  g_res.unwrap().text().unwrap();
    g_file.write_all(g_content.as_bytes()).unwrap();

    println!("genesis transactions fetched, file saved to: {:?}", g_path);
}