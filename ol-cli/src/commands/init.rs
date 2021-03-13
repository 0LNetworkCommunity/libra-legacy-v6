//! `start` subcommand - example of how to write a subcommand

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use crate::{
    prelude::*,
    config::{OlCliConfig, init_configs},
    commands::{CONFIG_FILE, home_path},
    check,
};
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
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
        let config = app_config();
        println!("Node URL: {}", &config.node_url);
        println!("Upstream Node URL: {}", &config.upstream_node_url);
        println!("\nEnter new settings to overwrite config file: {}", CONFIG_FILE);
        init_configs(Some(home_path()));
        check::init_cache()
    }
}

impl config::Override<OlCliConfig> for StartCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(
        &self,
        config: OlCliConfig,
    ) -> Result<OlCliConfig, FrameworkError> {
        // if !self.node_url.is_empty() {
        //     config.node_url = "No URL Provided".to_owned();
        // }
        Ok(config)
    }
}
