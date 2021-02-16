//! `start` subcommand - example of how to write a subcommand
use crate::{config::MinerConfig, test_tx_swarm::{swarm_miner, swarm_onboarding}};
/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use std::path::PathBuf;


/// `swarm` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct SwarmCmd {
    #[options(help = "Test the onboading transaction.")]
    init: bool,
    #[options(help = "The home directory where the blocks will be stored")]
    swarm_path: Option<PathBuf>, 
}

impl Runnable for SwarmCmd {
    /// Start the application.
    fn run(&self) {        
        println!("Testing Submit tx to Swarm.");
        let path: PathBuf;
    
        // Note, the convention is to run this tests from <project_root>/, and to start swarm with a temp path in <project root>/swarm_temp/
        if self.swarm_path.is_some() { path = self.swarm_path.as_ref().unwrap().to_owned() }
        else { path = PathBuf::from("./swarm_temp") }

        if self.init {
            swarm_onboarding(path);
        } else {
            swarm_miner(path);
        }
    }
}

impl config::Override<MinerConfig> for SwarmCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
        Ok(config)
    }
}
