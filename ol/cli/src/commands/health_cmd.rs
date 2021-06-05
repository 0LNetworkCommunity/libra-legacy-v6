//! `monitor-cmd` subcommand

use crate::{check, entrypoint, node::client, node::node::Node, prelude::app_config};
use abscissa_core::{Command, Options, Runnable};

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
    live: bool,
}

impl Runnable for HealthCmd {
    /// Start the application.
    fn run(&self) {
        let args = entrypoint::get_args();
        let is_swarm = *&args.swarm_path.is_some();
        let mut cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &mut cfg).unwrap();
        let mut node = Node::new(client, cfg, is_swarm);

        check::runner::run_checks(&mut node, false, self.live, true, false);
    }
}
