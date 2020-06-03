//! `start` subcommand - example of how to write a subcommand

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use crate::prelude::*;

use crate::config::OlMinerConfig;
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use vdf::{VDFParams, WesolowskiVDFParams, VDF};


/// `start` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct StartCmd {
    /// To whom are we saying hello?
    #[options(free)]
    recipient: Vec<String>,
}




impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
        let config = app_config();

        let int_size_bits = 2048;

        let vdf:Box<dyn VDF> = Box::new(WesolowskiVDFParams(int_size_bits).new());

        let proof = vdf
        .solve(&config.gen_preimage(), config.chain_info.block_size)
        .expect("iterations should have been valiated earlier");
        
        println!("{}", hex::encode(proof))

        
    }
}

impl config::Override<OlMinerConfig> for StartCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(
        &self,
        mut config: OlMinerConfig,
    ) -> Result<OlMinerConfig, FrameworkError> {


        Ok(config)
    }
}
