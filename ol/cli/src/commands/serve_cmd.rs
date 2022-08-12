//! `serve-cmd` subcommand

use std::process::exit;

use crate::{
    entrypoint,
    node::{client, node::Node},
    prelude::app_config,
    server,
};
use abscissa_core::{Command, Options, Runnable};

#[derive(Command, Debug, Options)]
pub struct ServeCmd {
    /// Start healthcheck runner
    #[options(
        short = "c",
        help = "deprecation notice: -c is no longer valid. Previously it was necessary if healthchecks were to be updated while server is running, but now we assume that is the intention of the user."
    )]
    run_checks: bool,
    /// Update the web files
    #[options(no_short, help = "update web files for server")]
    update: bool,
}

impl Runnable for ServeCmd {
    /// Start the application.
    fn run(&self) {
        let args = entrypoint::get_args();
        let is_swarm = *&args.swarm_path.is_some();
        let mut cfg = app_config().clone();
        if self.update {
            server::update_web(&cfg.workspace.node_home);
        } else {
            let client = match client::pick_client(args.swarm_path, &mut cfg) {
                Ok(c) => c,
                Err(e) => {
                    println!(
                        "ERROR: could not create client connection, message: {:?}",
                        e
                    );
                    exit(1);
                }
            };
            let mut node = Node::new(client, &cfg, is_swarm);
            server::init(&mut node, true);
            server::start_server(node, true);
        }
    }
}
