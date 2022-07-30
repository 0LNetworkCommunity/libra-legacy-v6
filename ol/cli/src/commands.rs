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

mod health_cmd;
pub mod init_cmd;
mod mgmt_cmd;
mod pilot_cmd;
pub mod query_cmd;
mod restore_cmd;
mod serve_cmd;
mod start_cmd;
mod version;
mod whoami_cmd;

use self::{
    health_cmd::HealthCmd, init_cmd::InitCmd, mgmt_cmd::MgmtCmd, pilot_cmd::PilotCmd,
    query_cmd::QueryCmd, restore_cmd::RestoreCmd, serve_cmd::ServeCmd, start_cmd::StartCmd,
    version::VersionCmd, whoami_cmd::WhoamiCmd,
};

use crate::config::AppCfg;
use crate::entrypoint;
use abscissa_core::{
    config::Override, Command, Configurable, FrameworkError, Help, Options, Runnable,
};

use std::path::PathBuf;

/// Filename for all 0L configs
pub const CONFIG_FILE: &str = "0L.toml";

/// OlCli Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum OlCliCmd {
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `start` subcommand
    #[options(help = "initialize the 0L configs")]
    Init(InitCmd),

    /// The `version` subcommand
    Version(VersionCmd),

    /// The `management` subcommand
    #[options(help = "management tools")]
    Mgmt(MgmtCmd),

    /// The `serve` subcommand
    #[options(help = "serve the monitor over http")]
    Serve(ServeCmd),

    /// The `restore` subcommand
    #[options(help = "restore the database from the epoch-archive repository")]
    Restore(RestoreCmd),

    /// The `query` subcommand
    #[options(help = "run simple queries through subcommands, prints the value to stdout")]
    Query(QueryCmd),

    /// The `health` subcommand
    #[options(
        help = "run healthcheck on the account, node, and displays some network information"
    )]
    Health(HealthCmd),

    /// The `pilot` subcommand, for explorer
    #[options(help = "run pilot command, which triggers needed services")]
    Pilot(PilotCmd),

    /// The `start` subcommand
    #[options(help = "start 0L services")]
    Start(StartCmd),

    /// The `whoami` subcommand
    #[options(help = "show public keys and network protocols")]
    Whoami(WhoamiCmd),
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<AppCfg> for OlCliCmd {
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

    /// Apply changes to the config after it's been loaded, e.g. overriding
    /// values in a config file using command-line options.
    ///
    /// This can be safely deleted if you don't want to override config
    /// settings from command-line options.
    fn process_config(&self, config: AppCfg) -> Result<AppCfg, FrameworkError> {
        match self {
            OlCliCmd::Init(cmd) => cmd.override_config(config),
            _ => Ok(config),
        }
    }
}
