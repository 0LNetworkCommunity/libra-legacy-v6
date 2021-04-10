//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::{application::app_config};
use abscissa_core::{Command, Options, Runnable, status_warn};
use ol_cli::commands::init_cmd;
use std::{path::PathBuf};

// TODO: duplicated for convenience, deprecate in favor of ol_cli
/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    #[options(help = "home path for miner app")]
    path: Option<PathBuf>,
    #[options(help = "Skip miner app configs")]
    skip_miner: bool,
    #[options(help = "Skip validator init")]
    skip_val: bool,
}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        status_warn!("deprecation notice: `miner init` will be removed in favor of `ol-cli init`");

        let (authkey, account, wallet) = keygen::account_from_prompt();
        let mut miner_config = app_config().to_owned();
        
        if !self.skip_miner { miner_config = init_cmd::initialize_miner(authkey, account, 
            &self.path).unwrap() };
        if !self.skip_val { init_cmd::initialize_validator(&wallet, &miner_config).unwrap() };
    }
}

// pub fn initialize_miner(authkey: AuthenticationKey, account: AccountAddress, path: &Option<PathBuf>) -> Result <MinerConfig, Error>{
//     let EntryPointTxsCmd { swarm_path } = entrypoint::get_args();
//     let miner_config = MinerConfig::init_miner_configs(authkey, account, path, swarm_path);
//     Ok(miner_config)
// }

// pub fn initialize_validator(wallet: &WalletLibrary, miner_config: &MinerConfig) -> Result <(), Error>{
//     let home_dir = &miner_config.workspace.node_home;
//     let keys = KeyScheme::new(wallet);
//     let namespace = miner_config.profile.auth_key.to_owned();
//     init::key_store_init(home_dir, &namespace, keys, false);
//     key::set_operator_key(home_dir, &namespace);
//     key::set_owner_key(home_dir, &namespace);

//     Ok(())
// }
