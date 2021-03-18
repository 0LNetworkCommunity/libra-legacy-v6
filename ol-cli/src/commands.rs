//! OlCli Subcommands
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

mod init;
mod version;
mod genesis_cmd;
mod bal_cmd;
mod resource_cmd;
mod height_cmd;
mod compare_cmd;
mod monitor_cmd;
mod mgmt_cmd;
mod serve_cmd;
mod restore_cmd;
mod sm_cmd;
mod onboard_cmd;

use self::{
    init::StartCmd,
    version::VersionCmd,
    genesis_cmd::GenesisCmd,
    bal_cmd::BalCmd,
    resource_cmd::ResourceCmd,
    height_cmd::HeightCmd,
    compare_cmd::CompareCmd,
    monitor_cmd::MonitorCmd,
    mgmt_cmd::MgmtCmd,
    serve_cmd::ServeCmd,
    restore_cmd::RestoreCmd,
    sm_cmd::SMCmd,
    onboard_cmd::OnboardCmd,
};

use crate::config::OlCliConfig;
use abscissa_core::{
    config::Override, Command, Configurable, FrameworkError, Help, Options, Runnable,
};
use std::path::PathBuf;
use dirs;
use libra_global_constants::NODE_HOME;

/// OlCli Configuration Filename
pub const CONFIG_FILE: &str = "ol_cli.toml";

/// OlCli Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum OlCliCmd {
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `start` subcommand
    #[options(help = "initialize the application")]
    Init(StartCmd),

    /// The `version` subcommand
    Version(VersionCmd),

    /// The `genesis` subcommand
    #[options(help = "get files")]
    Genesis(GenesisCmd),

    /// The `bal` subcommand
    #[options(help = "get balance")]
    Bal(BalCmd),

    /// The `resource` subcommand
    #[options(help = "get account resources")]
    Resource(ResourceCmd),

    /// The `height` subcommand
    #[options(help = "get blockchain height")]
    Height(HeightCmd),

    /// The `compare` subcommand
    #[options(help = "compare sync states between two nodes")]
    Compare(CompareCmd),

    /// The `monitor` subcommand
    #[options(help = "monitor the node and upstream")]
    Monitor(MonitorCmd),

    /// The `management` subcommand
    #[options(help = "management tools")]
    Mgmt(MgmtCmd),

    /// The `serve` subcommand
    #[options(help = "serve the monitor over http")]
    Serve(ServeCmd),

    /// The `restore` subcommand
    #[options(help = "serve the monitor over http")]
    Restore(RestoreCmd),

    /// The `state machine` subcommand
    #[options(help = "state machine")]
    Sm(SMCmd),    

    /// The `onboard` subcommand
    #[options(help = "onboard daemon")]
    Onboard(OnboardCmd),        
}

/// Get home path for all 0L apps
pub fn home_path() -> PathBuf{
    let mut config_path = dirs::home_dir().unwrap();
    config_path.push(NODE_HOME);
    // config_path.push(CONFIG_FILE);
    config_path
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<OlCliConfig> for OlCliCmd {
    /// Location of the configuration file
    fn config_path(&self) -> Option<PathBuf> {
        // Check if the config file exists, and if it does not, ignore it.
        // If you'd like for a missing configuration file to be a hard error
        // instead, always return `Some(CONFIG_FILE)` here.

        let mut config_path = home_path();
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
    fn process_config(
        &self,
        config: OlCliConfig,
    ) -> Result<OlCliConfig, FrameworkError> {
        match self {
            OlCliCmd::Init(cmd) => cmd.override_config(config),
            _ => Ok(config),
        }
    }
}
