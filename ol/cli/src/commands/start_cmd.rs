//! `start-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{check::{self, pilot}, entrypoint, node::client, node::node::Node, prelude::app_config};

/// `start` subcommand

#[derive(Command, Debug, Options)]
pub struct StartCmd {
    /// Silent mode, defaults to verbose
    #[options(short = "s", help = "silent mode, no prints")]
    silent: bool,
    /// Check if DB needs to be restored.
    #[options(short = "r", help = "check if DB bootstraps if not will attempt retore")]
    restore: bool
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
      let args = entrypoint::get_args();
      let mut cfg = app_config().clone();
      let client = client::pick_client(args.swarm_path, &mut cfg).unwrap().0;
      let mut node = Node::new(client, cfg);
      if *&self.restore { pilot::maybe_restore_db(&mut node, !self.silent); }
      check::runner::run_checks(&mut node, true ,true, !self.silent, !self.silent);
    }
}
