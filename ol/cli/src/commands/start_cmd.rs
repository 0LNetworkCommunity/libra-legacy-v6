//! `start-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{check, node::client, entrypoint, node::node::Node, prelude::app_config};

/// `pilot` subcommand

#[derive(Command, Debug, Options)]
pub struct StartCmd {
    /// Runs once, defaults to continuous
    #[options(short = "o", help = "run once and exit, not continuous")]
    once: bool,
    /// Silent mode, defaults to verbose
    #[options(short = "s", help = "silent mode, no prints")]
    silent: bool
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
      let args = entrypoint::get_args();
      let mut cfg = app_config().clone();
      let client = client::pick_client(args.swarm_path, &mut cfg).unwrap().0;
      let mut node = Node::new(client, cfg);
      // let now = SystemTime::now();
      check::runner::run_checks(&mut node, true ,!self.once, !self.silent);
    }
}
