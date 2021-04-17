//! `monitor-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{check, node::client, entrypoint, node::node::Node, prelude::app_config};

/// `monitor-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct HealthCmd {
    /// Runs continuously
    #[options(no_short, help = "is live")]
    live: bool
}

impl Runnable for HealthCmd {
    /// Start the application.
    fn run(&self) {
      let args = entrypoint::get_args();
      let cfg = app_config().clone();
      let _address = if args.account.is_some() {
        args.account.unwrap()
      } else {
        cfg.profile.account
      };
      
      let client = client::pick_client(args.swarm_path, &cfg);
      let node = Node::new(client, cfg);

      check::runner::run_checks(node, self.live, true);
        // monitor::timer();

        // Your code goes here
    }
}
