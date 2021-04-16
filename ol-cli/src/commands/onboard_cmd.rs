//! `onboard-cmd` subcommand

use crate::{node::client, entrypoint, prelude::app_config, node::transitions, node::node::Node};
use abscissa_core::{Command, Options, Runnable};

/// `onboard-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct OnboardCmd {
    #[options(help = "advance to all next states without supervision")]
    autopilot: bool,

    #[options(help = "advance to the next state")]
    next: bool,

    #[options(help = "attempt to trigger actions at every state")]
    trigger_actions: bool,
}

impl Runnable for OnboardCmd {
    /// Start the application.
    fn run(&self) {
        let args = entrypoint::get_args();
        let cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &cfg);
        if !self.trigger_actions {
            println!("You can pass --trigger-actions or -t to attempt the next transition\n")
        }
        // let mut host = transitions::HostState::init(client, cfg);
        let node = Node::new(Some(client), cfg);
        let node_state = node.node_maybe_advance(*&self.trigger_actions, node).get_state();
        let miner_state = node.miner_maybe_advance(*&self.trigger_actions, node).get_state();

        println!(
            "\nNode state at exit: {:?}\nMiner state: {:?}",
            node_state,
            miner_state,
            // host.get_next_action()
        );
    }
}

// pub fn advance(client: LibraClient, trigger_actions: bool, cfg) {

// }
