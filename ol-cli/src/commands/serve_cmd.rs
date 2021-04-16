//! `serve-cmd` subcommand

use crate::{client, entrypoint, prelude::app_config, server};
use abscissa_core::{Command, Options, Runnable};

/// `serve-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct ServeCmd {}

impl Runnable for ServeCmd {
    /// Start the application.
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let cfg = app_config().clone();
        let address = if entry_args.account.is_some() {
            entry_args.account.unwrap()
        } else {
            
            cfg.profile.account
        };
        let client = client::pick_client(entry_args.swarm_path, &cfg);
        server::start_server(client, address);
    }
}
