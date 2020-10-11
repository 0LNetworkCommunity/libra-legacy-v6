//! `submit` subcommand

#![allow(clippy::never_loop)]
use crate::node_keys::NodePubKeys;
use abscissa_core::{Command, Options, Runnable};
use libra_wallet::{WalletLibrary};
use crate::config;
use toml;
use std::{
    fs,
    io::Write,
};

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {}

impl Runnable for KeygenCmd {
    /// Print version message
    fn run(&self) {
        let mut wallet = WalletLibrary::new();

        // let seed = Seed::new(&Mnemonic::from(&mnemonic).unwrap(), "0L");

        // let kf = KeyFactory::new(&seed).unwrap();
        // let child_0 = kf.private_child(ChildNumber::new(0)).unwrap();
        // let child_1 = kf.private_child(ChildNumber::new(1)).unwrap();
        // let child_2 = kf.private_child(ChildNumber::new(2)).unwrap();
        // let child_3 = kf.private_child(ChildNumber::new(3)).unwrap();
        // // let child_4 = kf.private_child(ChildNumber::new(4)).unwrap();
      

        // let kf = wallet.key_factory;
        // let child_0 = kf.private_child(ChildNumber::new(0)).unwrap();
        // let child_1 = kf.private_child(ChildNumber::new(1)).unwrap();
        // let child_2 = kf.private_child(ChildNumber::new(2)).unwrap();
        // let child_3 = kf.private_child(ChildNumber::new(3)).unwrap();
      

        let (auth_key, child_number) = wallet.new_address().expect("Could not generate address");

        dbg!(&child_number);

        let mnemonic_string = wallet.mnemonic();
        
        let mut miner_configs = config::OlMinerConfig::default();
        miner_configs.profile.auth_key = auth_key.to_string();
        miner_configs.profile.account = Some(auth_key.derived_address().to_string());

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
        WRITE THIS DOWN NOW. This is the last time you will see this mnemonic. It is not saved anywhere. Nobody can help you if you lose it.\n\
        ---------\n\
        {}\n", &mnemonic_string.as_str());


        let keys = NodePubKeys::new_from_mnemonic(mnemonic_string);
        dbg!(&keys);
    }
}


#[test]
fn wallet () { 
    // let mut wallet = WalletLibrary::new();

    let mut wallet = WalletLibrary::new();

    let (auth_key, child_number) = wallet.new_address().expect("Could not generate address");
    let mnemonic_string = wallet.mnemonic(); //wallet

    println!("auth_key:\n{:?}", auth_key.to_string());
    println!("child_number:\n{:?}", child_number);
    println!("mnemonic:\n{}", mnemonic_string);

    // let mnemonic_string = r#"average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice"#;

    let mut wallet = WalletLibrary::new_from_string(&mnemonic_string);

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