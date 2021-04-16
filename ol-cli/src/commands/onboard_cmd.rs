//! `onboard-cmd` subcommand

use crate::{client, entrypoint, transitions};
use abscissa_core::{Command, Options, Runnable};
use cli::libra_client::LibraClient;

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
        let client = client::pick_client(args.swarm_path);
        if !self.trigger_actions {
            println!("You can pass --trigger-actions or -t to attempt the next transition\n")
        }
        advance(client, self.trigger_actions)
    }
}

pub fn advance(client: LibraClient, trigger_actions: bool) {
    let mut host = transitions::HostState::init(client);
    let node_state = host.node_maybe_advance(trigger_actions).get_state();
    let miner_state = host.miner_maybe_advance(trigger_actions).get_state();

    println!(
        "\nNode state at exit: {:?}\nMiner state: {:?}",
        node_state,
        miner_state,
        // host.get_next_action()
    );
}
