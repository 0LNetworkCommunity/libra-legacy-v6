//! `onboard-cmd` subcommand

use crate::transitions;
use std::{thread, time::Duration};
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
        let trigger_actions = self.trigger_actions;
        let trigger_actions_str = format!("trigger_actions: {}", trigger_actions);
        if self.autopilot {
            loop {
                println!("Running onboarding autopilot, {}", trigger_actions_str);
                thread::sleep(Duration::from_millis(10_000));
                let _state = transitions::NodeState::init()
                    .maybe_advance(trigger_actions)
                    .get_state();
            }
        } 
        else if self.next {
            println!("Running manual onboarding, {}", trigger_actions_str);
            let state = transitions::NodeState::init()
                .maybe_advance(trigger_actions)
                .get_state();
            println!("Onboarding stage at exit: {:?}", state);
        } 
    }
}