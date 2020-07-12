//! `start` subcommand - example of how to write a subcommand

// use crate::block::Block;
use crate::block::*;
use crate::config::OlMinerConfig;
use crate::prelude::*;
use anyhow::Error;
use libra_types::waypoint::Waypoint;
use rustyline::error::ReadlineError;
use rustyline::Editor;

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};

/// `start` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct StartCmd {
    #[options(help = "Provide a waypoint for the libra chain")]
    waypoint: String, //Option<Waypoint>,
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();

        let mut rl = Editor::<()>::new();

        println!("Enter your 0L mnemonic");

        let readline = rl.readline(">> ");

        match readline {
            Ok(line) => {
                println!("Mnemonic: \n{}", line);

                let parsed_waypoint: Result<Waypoint, Error> = self.waypoint.parse();
                match parsed_waypoint {
                    Ok(v) => {
                        println!("Using Waypoint from CLI args:\n{}", v);
                    }
                    Err(e) => {
                        println!("Waypoint cannot be parsed, check delimiter: Error:\n{:?}\n WILL FALLBACK TO WAYPOINT FROM ol_miner.toml", miner_configs.chain_info.base_waypoint);
                        return;
                    }
                }

                build_block::mine_and_submit(&miner_configs, line, parsed_waypoint.unwrap());
            }
            Err(ReadlineError::Interrupted) => {
                println!("CTRL-C");
            }
            Err(ReadlineError::Eof) => {
                println!("CTRL-D");
            }
            Err(err) => {
                println!("Error: {:?}", err);
            }
        }

        status_ok!("Start mining...", "ok"); //TODO: Print something more interesting here.
    }
}

impl config::Override<OlMinerConfig> for StartCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: OlMinerConfig) -> Result<OlMinerConfig, FrameworkError> {
        Ok(config)
    }
}
