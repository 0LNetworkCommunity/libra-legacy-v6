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

mod keygen_cmd;
mod start;
mod version;
mod onboard;
mod swarm_test;
mod genesis;
mod ceremony_util_cmd;
mod create_account;
mod init;

use self::{
    start::StartCmd,
    version::VersionCmd,
    onboard::OnboardCmd,
    swarm_test::SwarmCmd,
    genesis::GenesisCmd,
    keygen_cmd::KeygenCmd,
    ceremony_util_cmd::CeremonyUtilCmd,
    create_account::CreateCmd,
    init::InitCmd,
};
use crate::config::MinerConfig;
use abscissa_core::{
    config::Override, Command, Configurable, FrameworkError, Help, Options, Runnable,
};
use std::path::PathBuf;
use dirs;
use libra_global_constants::NODE_HOME;

/// MinerApp Configuration Filename
pub const CONFIG_FILE: &str = "miner.toml";

/// MinerApp Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum MinerCmd {
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `genesis` subcommand
    #[options(help = "mine the 0th block of the tower")]
    Genesis(GenesisCmd),

    /// The `start` subcommand
    #[options(help = "start mining blocks")]
    Start(StartCmd),

    /// The `version` subcommand
    #[options(help = "display version information")]
    Version(VersionCmd),

    /// The `keygen` subcommand
    #[options(help = "generate keys")]
    Keygen(KeygenCmd),

    /// The `keygen` subcommand
    #[options(help = "wizard for genesis ceremony configurations")]
    Ceremony(CeremonyUtilCmd),

    /// The `onboard` subcommand
    #[options(help = "onboard a new miner with a block_0.json proof")]
    Onboard(OnboardCmd),
    
    /// The `swarm` subcommand
    #[options(help = "test connection to a local swarm")]
    Swarm(SwarmCmd),

    /// The `swarm` subcommand
    #[options(help = "wizard to create accounts and local configs")]
    Create(CreateCmd),

    /// The `swarm` subcommand
    #[options(help = "initialize miner configs miner.toml")]
    Init(InitCmd),
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<MinerConfig> for MinerCmd {
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

    /// Apply changes to the config after it's been loaded, e.g. overriding
    /// values in a config file using command-line options.
    ///
    /// This can be safely deleted if you don't want to override config
    /// settings from command-line options.
    fn process_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
        match self {
            MinerCmd::Start(cmd) => cmd.override_config(config),
            _ => Ok(config),
        }
    }
}
