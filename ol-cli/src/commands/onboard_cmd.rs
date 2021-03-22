//! `onboard-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::transitions;

/// `onboard-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct OnboardCmd {
    /// attempt to trigger actions at every state
    #[options(short = "t", help = "attempt to trigger actions at every state")]
    trigger_actions: bool,
    // "free" arguments don't have an associated flag
    #[options(free)]
    free_args: Vec<String>,
}

impl Runnable for OnboardCmd {

    /// Start the application.
    fn run(&self) {
        if self.free_args.clone().into_iter().find(|x| x == "next").is_some() {
            let state = transitions::NodeState::init()
            .maybe_advance(self.trigger_actions)
            .get_state();
            dbg!(state);
        } 
    }
}