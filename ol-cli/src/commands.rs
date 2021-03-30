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
mod monitor_cmd;
mod mgmt_cmd;
mod serve_cmd;
mod restore_cmd;
mod onboard_cmd;
mod query_cmd;
mod check_cmd;
mod explorer_cmd;

use self::{
    init::StartCmd,
    version::VersionCmd,
    monitor_cmd::MonitorCmd,
    mgmt_cmd::MgmtCmd,
    serve_cmd::ServeCmd,
    restore_cmd::RestoreCmd,
    onboard_cmd::OnboardCmd,
    query_cmd::QueryCmd,
    check_cmd::CheckCmd,
};

use crate::config::OlCliConfig;
use abscissa_core::{
    config::Override, Command, Configurable, FrameworkError, Help, Options, Runnable,
};
use std::path::PathBuf;
use dirs;
use libra_global_constants::NODE_HOME;
use crate::commands::explorer_cmd::ExplorerCMD;

/// Filename for all 0L configs
pub const CONFIG_FILE: &str = "0L.toml";

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

    /// The `onboard` subcommand
    #[options(help = "onboarding actions")]
    Onboard(OnboardCmd),        

    /// The `query` subcommand
    #[options(help = "query helpers")]
    Query(QueryCmd), 

    /// The `query` subcommand
    #[options(help = "query helpers")]
    Check(CheckCmd),

    /// The `explorer` subcommand
    #[options(help = "query helpers")]
    Explorer(ExplorerCMD),

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
