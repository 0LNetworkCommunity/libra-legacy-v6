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
mod start_cmd;
mod version_cmd;
mod swarm_test_cmd;
mod zero_cmd;
mod ceremony_cmd;
mod manifest_cmd;
mod init_cmd;
mod wizard_user_cmd;
mod wizard_val_cmd;
mod wizard_fn_cmd;
mod files_cmd;

use self::{
    start_cmd::StartCmd,
    version_cmd::VersionCmd,
    swarm_test_cmd::SwarmCmd,
    zero_cmd::ZeroCmd,
    keygen_cmd::KeygenCmd,
    ceremony_cmd::CeremonyUtilCmd,
    wizard_user_cmd::UserWizardCmd,
    init_cmd::InitCmd,
    wizard_val_cmd::ValWizardCmd,
    wizard_fn_cmd::FnWizardCmd,
    files_cmd::FilesCmd,
    manifest_cmd::ManifestCmd,
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
    Zero(ZeroCmd),

    /// The `start` subcommand
    #[options(help = "start mining blocks")]
    Start(StartCmd),

    /// The `version` subcommand
    #[options(help = "display version information")]
    Version(VersionCmd),

    /// The `keygen` subcommand
    #[options(help = "generate keys")]
    Keygen(KeygenCmd),

    /// The `ceremony` subcommand
    #[options(help = "wizard for genesis ceremony configurations")]
    Ceremony(CeremonyUtilCmd),
    
    /// The `swarm` subcommand
    #[options(help = "test connection to a local swarm")]
    Swarm(SwarmCmd),

    /// The `user_wizard` subcommand
    #[options(help = "wizard to create accounts and local configs")]
    UserWizard(UserWizardCmd),

    /// The `init` subcommand
    #[options(help = "initialize miner configs miner.toml")]
    Init(InitCmd),

    /// The `val_wizard` subcommand
    #[options(help = "run all steps for validator onboarding")]
    ValWizard(ValWizardCmd),

    /// The `fn_wizard` subcommand
    #[options(help = "run all steps for fullnode config")]
    FnWizard(FnWizardCmd),
    
    /// The `genesis` subcommand
    #[options(help = "generate validator files")]
    Files(FilesCmd),

    /// The `manifest` subcommand
    #[options(help = "account manifest")]
    Manifest(ManifestCmd),
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
