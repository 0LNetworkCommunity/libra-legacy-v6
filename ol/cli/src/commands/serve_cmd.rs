//! `serve-cmd` subcommand

use crate::{entrypoint, node::{client, node::Node}, prelude::app_config, server};
use abscissa_core::{Command, Options, Runnable};
#[derive(Command, Debug, Options)]
pub struct ServeCmd {
    /// Start healthcheck runner
    #[options(short = "c", help = "start health check runner")]
    run_checks: bool,
    /// Update the web files
    #[options(no_short, help = "update web files for server")]
    update: bool
}

impl Runnable for ServeCmd {
    /// Start the application.
    fn run(&self) {
        let args = entrypoint::get_args();
        let cfg = app_config().clone();
        if self.update {
          server::update_web(&cfg.workspace.node_home);
        } else {
          let client = client::pick_client(args.swarm_path, &cfg).unwrap().0;
          let node = Node::new(client, cfg);
          server::start_server(node, self.run_checks);
        }
    }
}
