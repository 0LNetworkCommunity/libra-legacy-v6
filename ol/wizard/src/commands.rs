//! MinerApp Subcommands
mod files_cmd;
mod version_cmd;
mod wizard_fn_cmd;
mod wizard_user_cmd;
mod wizard_val_cmd;

use self::{
    version_cmd::VersionCmd, wizard_fn_cmd::FnWizardCmd, wizard_user_cmd::UserWizardCmd,
    wizard_val_cmd::ValWizardCmd,
};
use abscissa_core::{Command, Configurable, Help, Options, Runnable};
use dirs;
use libra_global_constants::NODE_HOME;
use std::path::PathBuf;
use ol_types::config::OlCliConfig;
/// MinerApp Configuration Filename
pub const CONFIG_FILE: &str = "0L.toml";

/// MinerApp Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum WizCmd {
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `version` subcommand
    #[options(help = "display version information")]
    Version(VersionCmd),

    /// The `user_wizard` subcommand
    #[options(help = "wizard to create accounts and local configs")]
    User(UserWizardCmd),

    /// The `val_wizard` subcommand
    #[options(help = "create all files for validator onboarding")]
    Val(ValWizardCmd),

    /// The `fn_wizard` subcommand
    #[options(help = "create all files for fullnode config")]
    Fullnode(FnWizardCmd),
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<OlCliConfig> for WizCmd {
    /// Location of the configuration file
    fn config_path(&self) -> Option<PathBuf> {
        // Check if the config file exists, and if it does not, ignore it.
        // If you'd like for a missing configuration file to be a hard error
        // instead, always return `Some(CONFIG_FILE)` here.

        let mut config_path = dirs::home_dir().unwrap();
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
    // fn process_config(&self, config: OlCliConfig) -> Result<OlCliConfig, FrameworkError> {
    //     match self {
    //         MinerCmd::Start(cmd) => cmd.override_config(config),
    //         _ => Ok(config),
    //     }
    // }
}
