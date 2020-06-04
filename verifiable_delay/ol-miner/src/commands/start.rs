//! `start` subcommand - example of how to write a subcommand


use crate::application::SECURITY_PARAM;
use crate::block::Block;
use crate::config::OlMinerConfig;
use crate::delay::Delay;

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use crate::prelude::*;
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use glob::glob;
use serde::Serialize;
use std::{fs, io::Write, path::Path};
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
        let blocks_dir = Path::new(&config.chain_info.block_dir);

        let (current_block_number, current_block_path) = {
            //Check for existing blocks

            if !blocks_dir.exists() {
                fs::create_dir(blocks_dir).unwrap();
                (0u64, None)
            } else {
                let mut max_block = 0u64;
                let mut max_block_path = None;
                for entry in glob(&format!("{}/block_*.json", blocks_dir.display()))
                    .expect("Failed to read glob pattern")
                {
                    if let Ok(entry) = entry {
                        if let Some(stem) = entry.file_stem() {
                            if let Some(stem_string) = stem.to_str() {
                                if let Some(blocknumber) = stem_string.strip_prefix("block_") {
                                    let blocknumber = blocknumber.parse::<u64>().unwrap();
                                    if blocknumber > max_block {
                                        max_block = blocknumber;
                                        max_block_path = Some(entry);
                                    }
                                }
                            }
                        }
                    }
                }
                (max_block, max_block_path)
            }
        };

        let block = Block {
            height: current_block_number + 1,
            // note: do_delay() sigature is (challenge, delay difficulty)
            data: Delay::do_delay(&config.gen_preimage(), config.chain_info.block_size),
        };

        let mut latest_block_path = blocks_dir.to_path_buf();
        latest_block_path.push(format!("block_{}.json", current_block_number + 1));
        let mut file = fs::File::create(&latest_block_path).unwrap();

        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .unwrap();

    }
}

impl config::Override<OlMinerConfig> for StartCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, mut config: OlMinerConfig) -> Result<OlMinerConfig, FrameworkError> {
        Ok(config)
    }
}
