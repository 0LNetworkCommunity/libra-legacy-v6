//! `start-cmd` subcommand

use std::process::exit;

use crate::{check, entrypoint, node::client, node::node::Node, prelude::app_config};
use abscissa_core::{Command, Options, Runnable};

/// `start` subcommand

#[derive(Command, Debug, Options)]
pub struct StartCmd {
    /// Silent mode, defaults to verbose
    #[options(short = "q", help = "silent mode, no prints")]
    quiet: bool,
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
        let args = entrypoint::get_args();
        let is_swarm = *&args.swarm_path.is_some();
        let mut cfg = app_config().clone();
        let client = match client::pick_client(args.swarm_path, &mut cfg) {
            Ok(c) => c,
            Err(e) => {
                println!("ERROR: Could not create a client to connect to network. Will not be able to send txs. Exiting. Message: {:?}", e );
                exit(1);
            }
        };
        let mut node = Node::new(client, &cfg, is_swarm);

        check::runner::run_checks(&mut node, true, true, !self.quiet, !self.quiet);
    }
}
