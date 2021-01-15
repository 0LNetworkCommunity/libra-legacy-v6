//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{account, block::{build_block}, config, delay, keygen, node_keys::KeyScheme};
use abscissa_core::{Command, Options, Runnable};
use std::path::PathBuf;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateCmd {
    #[options(help = "path to write account manifest")]
    path: Option<PathBuf>,
    #[options(help = "path to file to be checked")]
    check: bool,
    #[options(help = "regenerates account manifest from mnemonic")]
    fix: bool,
    #[options(help = "creates a validator account")]
    is_validator: bool,
    #[options(help = "use an existing block_0.json file and skip mining")]
    block_zero: Option<PathBuf>,
}

impl Runnable for CreateCmd {
    /// Print version message
    fn run(&self) {
        
        let path = self.path.clone().unwrap_or_else(|| PathBuf::from("."));
        if self.check {
            check(path);
        } else {
            create(path, self.fix, self.is_validator, &self.block_zero);
        }
    }
}

fn create(path: PathBuf, is_fix: bool, is_validator: bool, block_zero: &Option<PathBuf>) {
        let mut miner_configs = config::MinerConfig::default();
        let keys;

        if is_fix {
            let mnemonic_string = rpassword::read_password_from_tty(Some("\u{1F511} ")).unwrap();
            let (authkey, account, wallet) = keygen::get_account_from_mnem(mnemonic_string);

            miner_configs.profile.auth_key = authkey.to_string();
            miner_configs.profile.account = account;
            keys = KeyScheme::new(wallet);
        } else {
            let (authkey, account, wallet) = keygen::keygen();
            miner_configs.profile.auth_key = authkey.to_string();
            miner_configs.profile.account = account;
            keys = KeyScheme::new(wallet);
        }

        let block;
        if let Some(block_path) = block_zero {
            block = build_block::parse_block_file(block_path.to_owned());
        } else {
            block = build_block::write_genesis(&miner_configs);
        }

        if is_validator {
            account::ValConfigs::new(
                block,
                keys,  
                miner_configs.profile.ip.to_string()
            ).create_manifest(path);

        } else {
            account::UserConfigs::new(block)
            .create_manifest(path);
        } 
}

/// Checks the format of the account manifest, including vdf proof
fn check(path: PathBuf) {
    let user_data = account::UserConfigs::get_init_data(&path).expect(&format!("could not parse manifest in {:?}", &path));
    match delay::verify(&user_data.block_zero.preimage, &user_data.block_zero.proof) {
        true => println!("Proof verified in {:?}", &path),
        false => println!("Invalid proof in {:?}", &path)
    }
}
