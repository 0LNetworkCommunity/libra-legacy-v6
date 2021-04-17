//! `serve-cmd` subcommand

use crate::{entrypoint, node::{client, node::Node}, prelude::app_config, server};
use abscissa_core::{Command, Options, Runnable};
#[derive(Command, Debug, Options)]
pub struct ServeCmd {}

impl Runnable for ServeCmd {
    /// Start the application.
    fn run(&self) {
        let args = entrypoint::get_args();
        let cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &cfg);
        let node = Node::new(client, cfg);
        server::start_server(node);
    }
}
