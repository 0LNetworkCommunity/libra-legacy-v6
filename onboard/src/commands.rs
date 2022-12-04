//! MinerApp Subcommands
pub mod genesis_files_cmd;
pub mod version_cmd;
// pub mod wizard_fn_cmd;
pub mod fix_cmd;
pub mod keygen_cmd;
pub mod wizard_fork_cmd;
pub mod wizard_user_cmd;
pub mod wizard_val_cmd;

use self::{
    fix_cmd::FixCmd, genesis_files_cmd::GenesisFilesCmd, keygen_cmd::KeygenCmd,
    version_cmd::VersionCmd, wizard_fork_cmd::ForkCmd, wizard_user_cmd::UserWizardCmd,
    wizard_val_cmd::ValWizardCmd,
};
use crate::entrypoint;
use abscissa_core::{Command, Configurable, Help, Options, Runnable};
use ol_types::config::AppCfg;
use std::path::PathBuf;

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

    /// The `user` subcommand
    #[options(help = "wizard to create accounts and local configs")]
    User(UserWizardCmd),

    /// The `val` subcommand
    #[options(help = "create all files for validator onboarding")]
    Val(ValWizardCmd),

    // /// The `fullnode` subcommand
    // #[options(help = "create all files for fullnode config")]
    // Fullnode(FnWizardCmd),
    /// The `keygen` subcommand
    #[options(help = "create new account and mnemonic")]
    Keygen(KeygenCmd),

    /// The `fix` subcommand
    #[options(help = "migrate account.json")]
    Fix(FixCmd),

    /// The `fork` subcommand
    #[options(help = "create configs for a fork, from genesis")]
    Fork(ForkCmd),

    /// The `genesis files` subcommand
    #[options(help = "fetch genesis.blob from a github repo")]
    GenesisFiles(GenesisFilesCmd),
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<AppCfg> for WizCmd {
    /// Location of the configuration file
    fn config_path(&self) -> Option<PathBuf> {
        // Check if the config file exists, and if it does not, ignore it.
        // If you'd like for a missing configuration file to be a hard error
        // instead, always return `Some(CONFIG_FILE)` here.

        let mut config_path = entrypoint::get_node_home();

        config_path.push(CONFIG_FILE);
        if config_path.exists() {
            // println!("initializing from config file: {:?}", config_path);
            Some(config_path)
        } else {
            // println!("config file not yet existing: {:?}", config_path);
            None
        }
    }
}
