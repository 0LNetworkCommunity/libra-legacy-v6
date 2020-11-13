//! `submit` subcommand

#![allow(clippy::never_loop)]
use abscissa_core::{Command, Options, Runnable};
use libra_wallet::WalletLibrary;
use crate::config;
use crate::commands::CONFIG_FILE;
use libra_global_constants::NODE_HOME;
use toml;
use std::{net::Ipv4Addr, fs, io::Write};
use rustyline::Editor;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {}

impl Runnable for KeygenCmd {
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

        let get_gh_token = rl.readline("Github Token: ").expect("Please enter a fun statement to go into genesis proof.");
        let token_path = miner_configs.workspace.node_home.join("github_token.txt");
        let file = fs::File::create(token_path.to_str().unwrap());
        file.unwrap().write(&get_gh_token.as_bytes())
        .expect("Could not write github_token.txt file");


        let readline = rl.readline("IP address of node: ").expect("Must enter an ip address, eg. 0.0.0.0");
        let ip_address: Ipv4Addr = readline.parse().expect("Could not parse IP address");
        
        let get_statement = rl.readline("Your statement: ").expect("Please enter a fun statement to go into genesis proof.");


        
        // Generate new keys
        let mut wallet = WalletLibrary::new();
        let mnemonic_string = wallet.mnemonic();
        // NOTE: Authkey uses the child number 0 by default
        let (auth_key, _) = wallet.new_address().expect("Could not generate address");

        miner_configs.profile.account = auth_key.derived_address();
        miner_configs.profile.auth_key = auth_key.to_string();
        miner_configs.profile.ip = ip_address;
        miner_configs.profile.statement = get_statement;
  
        let toml = toml::to_string(&miner_configs).unwrap();
        
        let mut miner_toml_path = miner_configs.workspace.node_home;
        miner_toml_path.push(CONFIG_FILE);
        let file = fs::File::create(&miner_toml_path);
        file.unwrap().write(&toml.as_bytes())
            .expect("Could not write toml file");

        //////////////// Info ////////////////
        
        println!("Saved to: {}\n\
        ==========================\n\n", miner_toml_path.display());

        println!("0L Auth Key:\n\
        You will need this in your miner.toml configs.\n\
        ---------\n\
        {:?}\n", &miner_configs.profile.auth_key);

        println!("0L Address:\n\
        This address is derived from your Auth Key, it has not yet been created on chain. You'll need to submit a genesis miner proof for that.\n\
        ---------\n\
        {:?}\n", &miner_configs.profile.account);

        println!("0L mnemonic:\n\
        WRITE THIS DOWN NOW. This is the last time you will see this mnemonic. It is not saved anywhere. Nobody can help you if you lose it.\n\
        ---------\n\
        {}\n", &mnemonic_string.as_str());
    }
}

#[test]
fn wallet() { 
    use libra_wallet::Mnemonic;
    // let mut wallet = WalletLibrary::new();

    let mut wallet = WalletLibrary::new();

    let (auth_key, child_number) = wallet.new_address().expect("Could not generate address");
    let mnemonic_string = wallet.mnemonic(); //wallet

    println!("auth_key:\n{:?}", auth_key.to_string());
    println!("child_number:\n{:?}", child_number);
    println!("mnemonic:\n{}", mnemonic_string);

    // let mnemonic_string = r#"average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice"#;

    let mut wallet = WalletLibrary::new_from_mnemonic(Mnemonic::from(&mnemonic_string).unwrap());

    // println!("wallet\n:{:?}", wallet);

    let (main_addr, child_number ) = wallet.new_address().unwrap();
    println!("wallet\n:{:?} === {:x}", child_number, main_addr);

    let vec_addresses = wallet.get_addresses().unwrap();

    println!("vec_addresses\n:{:?}", vec_addresses);

    // Expect this to be zero before we haven't populated the address map in the repo
    assert!(vec_addresses.len() == 1);
    // Empty hashmap should be fine
    // let mut vec_account_data = Vec::new();
}