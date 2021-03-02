//! MinerApp Subcommands
//!
//! This is where you specify the subcommands of your application.
//!
//! The default application comes with two subcommands:
//!
//! - `start`: launches the application
//! - `version`: print application version
//!
//! See the `impl Configurable` below for how to specify the path to the
//! application's configuration file.

mod init_cmd;
mod keygen_cmd;
mod create_account_cmd;
mod oracle_upgrade_cmd;
mod version_cmd;

use self::{
    init_cmd::InitCmd,
    keygen_cmd::KeygenCmd,
    create_account_cmd::CreateAccountCmd,
    oracle_upgrade_cmd::OracleUpgradeCmd,
    version_cmd::VersionCmd,
};
use crate::config::AppConfig;
use abscissa_core::{Command, Configurable, Help, Options, Runnable};
use std::path::PathBuf;
use dirs;
use libra_global_constants::NODE_HOME;

/// MinerApp Configuration Filename
pub const CONFIG_FILE: &str = "miner.toml";

/// MinerApp Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum TxsCmd {
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `init` subcommand
    #[options(help = "initialize miner configs miner.toml")]
    Init(InitCmd),

    /// The `keygen` subcommand
    #[options(help = "generate keys")]
    Keygen(KeygenCmd),

    /// The `create-account` subcommand
    #[options(help = "create user account")]
    CreateAccount(CreateAccountCmd),
    
    /// The `oracle-upgrade` subcommand
    #[options(help = "oracle upgrade")]
    OracleUpgrade(OracleUpgradeCmd),    

    /// The `version` subcommand
    #[options(help = "display version information")]
    Version(VersionCmd),
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<AppConfig> for TxsCmd {
    /// Location of the configuration file
    fn config_path(&self) -> Option<PathBuf> {
        // Check if the config file exists, and if it does not, ignore it.
        // If you'd like for a missing configuration file to be a hard error
        // instead, always return `Some(CONFIG_FILE)` here.

        let mut config_path = dirs::home_dir()
        .unwrap();
        config_path.push(NODE_HOME);
        config_path.push(CONFIG_FILE);

        if config_path.exists() {
            Some(config_path)
        } else {
            None
        }
    }
}
