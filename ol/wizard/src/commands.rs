//! MinerApp Subcommands
mod version_cmd;
mod wizard_user_cmd;
mod wizard_val_cmd;
mod wizard_fn_cmd;
mod files_cmd;

use self::{
    version_cmd::VersionCmd,
    wizard_user_cmd::UserWizardCmd,
    wizard_val_cmd::ValWizardCmd,
    wizard_fn_cmd::FnWizardCmd,
};
use crate::config::MinerConfig;
use abscissa_core::{
    config::Override, Command, Configurable, FrameworkError, Help, Options, Runnable,
};
use std::path::PathBuf;
use dirs;
use libra_global_constants::NODE_HOME;

/// MinerApp Configuration Filename
pub const CONFIG_FILE: &str = "0L.toml";

/// MinerApp Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum MinerCmd {
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `version` subcommand
    #[options(help = "display version information")]
    Version(VersionCmd),

    /// The `user_wizard` subcommand
    #[options(help = "wizard to create accounts and local configs")]
    UserWizard(UserWizardCmd),

    /// The `val_wizard` subcommand
    #[options(help = "create all files for validator onboarding")]
    ValWizard(ValWizardCmd),

    /// The `fn_wizard` subcommand
    #[options(help = "create all files for fullnode config")]
    FnWizard(FnWizardCmd),
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

    // /// Apply changes to the config after it's been loaded, e.g. overriding
    // /// values in a config file using command-line options.
    // ///
    // /// This can be safely deleted if you don't want to override config
    // /// settings from command-line options.
    // fn process_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
    //     match self {
    //         MinerCmd::Start(cmd) => cmd.override_config(config),
    //         _ => Ok(config),
    //     }
    // }
}
