//! `submit` subcommand

#![allow(clippy::never_loop)]
use abscissa_core::{Command, Options, Runnable};
use crate::config;
use crate::{keygen::keygen, commands::CONFIG_FILE, block::build_block};
use libra_global_constants::NODE_HOME;
use toml;
use std::{fs, io::Write};
use rustyline::Editor;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CeremonyUtilCmd {}

impl Runnable for CeremonyUtilCmd {
    /// Print version message
    fn run(&self) {
        println!("Miner not initialized, creating configs at {}", NODE_HOME);
        let mut miner_configs = config::MinerConfig::default();
        miner_configs.workspace.node_home = dirs::home_dir().unwrap();
        miner_configs.workspace.node_home.push(NODE_HOME);
        fs::create_dir_all(&miner_configs.workspace.node_home).unwrap();

        println!("Enter configs...");
        // Set up github token
        let mut rl = Editor::<()>::new();

        // Get the github token.
        let get_gh_token = rl.readline("Github Token: ").expect("Please enter a fun statement to go into genesis proof.");
        let token_path = miner_configs.workspace.node_home.join("github_token.txt");
        let file = fs::File::create(token_path.to_str().unwrap());
        file.unwrap().write(&get_gh_token.as_bytes())
        .expect("Could not write github_token.txt file");

        // Get the ip address of node.
        let readline = rl.readline("IP address of node: ").expect("Must enter an ip address, eg. 0.0.0.0");
        miner_configs.profile.ip = readline.parse().expect("Could not parse IP address");
        
        // Get optional statement which goes into genesis block
        miner_configs.profile.statement = rl.readline("Make a (fun) statement: ").expect("Please enter a fun statement to go into genesis proof.");

        // Generate new keys
        let (authkey, account) = keygen();
        miner_configs.profile.auth_key = authkey.to_string();
        miner_configs.profile.account = account;

        let toml = toml::to_string(&miner_configs).unwrap();
        let home_path = miner_configs.workspace.node_home.clone();
        let miner_toml_path = home_path.join(CONFIG_FILE);
        let file = fs::File::create(&miner_toml_path);
        file.unwrap().write(&toml.as_bytes())
            .expect("Could not write toml file");    


        build_block::mine_genesis(&miner_configs);

        println!("\nWelcome");
    }
}
