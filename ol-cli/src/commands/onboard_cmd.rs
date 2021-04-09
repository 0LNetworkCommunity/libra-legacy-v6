//! `onboard-cmd` subcommand

use crate::transitions;
use abscissa_core::{Command, Options, Runnable};
use std::{thread, time::Duration};

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
        if !self.trigger_actions {
            println!("You can pass --trigger-actions or -t to attempt the next transition\n")
        }
        if self.autopilot {
            loop {
                println!("Running onboarding autopilot\n");
                advance(self.trigger_actions);
                thread::sleep(Duration::from_millis(10_000));
            }
        } else {
            advance(self.trigger_actions)
        }
    }
}

pub fn advance(trigger_actions: bool) {
    let mut host = transitions::HostState::init();
    let node_state = host.maybe_advance(trigger_actions).get_state();
    let miner_state = host.miner_maybe_advance(trigger_actions).get_state();

    println!(
        "\nNode state at exit: {:?}\nMiner state: {:?}\nNext step for node: {:?}",
        node_state,
        miner_state,
        host.get_next_action()
    );
}
