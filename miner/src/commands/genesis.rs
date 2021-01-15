//! `start` subcommand - example of how to write a subcommand

use crate::{block::build_block, keygen,};
use crate::config::MinerConfig;
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{Command, Options, Runnable};

#[derive(Command, Debug, Options)]
pub struct GenesisCmd {}

impl Runnable for GenesisCmd {
    /// Start the application.
    fn run(&self) {
        let mut miner_configs = MinerConfig::default();
        
        println!("Enter your 0L mnemonic:");
        let mnemonic_string = rpassword::read_password_from_tty(Some("\u{1F511} ")).unwrap();
        let (authkey, account, _) = keygen::get_account_from_mnem(mnemonic_string);
        miner_configs.profile.auth_key = authkey.to_string();
        miner_configs.profile.account = account;
        build_block::write_genesis(&miner_configs);
    }
}
