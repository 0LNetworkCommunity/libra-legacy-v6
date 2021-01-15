//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{block::build_block, config, keygen, account, delay};
use abscissa_core::{Command, Options, Runnable};
use std::path::PathBuf;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct CreateCmd {
    #[options(help = "don't generate keys")]
    skip_keys: bool,
    #[options(help = "create a validator account, instead of user account")]
    val: bool,
    #[options(help = "path to write account manifest")]
    path: Option<PathBuf>,
    #[options(help = "path to file to be checked")]
    check: bool,

}

impl Runnable for CreateCmd {
    /// Print version message
    fn run(&self) {
        
        let path = self.path.clone().unwrap_or_else(|| PathBuf::from("."));
        if self.check {
            check(path);
        } else {
            create(path);
        }

    }


}

fn create(path: PathBuf) {
        let mut miner_configs = config::MinerConfig::default();
        let (authkey, account) = keygen::keygen();
        miner_configs.profile.auth_key = authkey.to_string();
        miner_configs.profile.account = account;
        let block = build_block::mine_genesis(&miner_configs);
        account::UserConfigs::new(block).create_user_manifest(path);
}

/// Checks the format of the account manifest, including vdf proof
fn check(path: PathBuf) {
    let user_data = account::UserConfigs::get_init_data(&path).expect(&format!("could not parse manifest in {:?}", &path));
    match delay::verify(&user_data.block_zero.preimage, &user_data.block_zero.proof) {
        true => println!("Proof verified in {:?}", &path),
        false => println!("Invalid proof in {:?}", &path)
    }
}
