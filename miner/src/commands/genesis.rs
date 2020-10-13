//! `start` subcommand - example of how to write a subcommand

use crate::{block::Block, block::ValConfigs, block::build_block, node_keys::NodePubKeys};
use crate::config::MinerConfig;
use crate::prelude::*;
use std::{fs, path::PathBuf};
use std::io::Write;

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use fs::File;
#[derive(Command, Debug, Options)]
pub struct GenesisCmd {
    // Option for setting path for the blocks/proofs that are mined.
    #[options(help = "The home directory where the blocks will be stored")]
    home: PathBuf, 
}

impl Runnable for GenesisCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();
        println!("Enter your 0L mnemonic:");
        let mnemonic_string = rpassword::read_password_from_tty(Some("\u{1F511} ")).unwrap();

        // Create blocks/block_0.json file.
        build_block::mine_genesis(&miner_configs);
        

        // Create val_init.json file.
        let keys = NodePubKeys::new_from_mnemonic(mnemonic_string);
        dbg!(&keys);

        let val_init_file = "./val_init.json";
        let json_path = miner_configs.workspace.miner_home;
        json_path.push("val_init.json");

        let val_configs = ValConfigs {
            /// Block zero of the onboarded miner
            block_zero: Block {
                height: 0,
                elapsed_secs: 0,
                preimage: hex::decode("0").unwrap(),
                proof: hex::decode("0").unwrap(),
            },
            consensus_pubkey: vec!(),
            validator_network_identity_pubkey: vec!(),
            validator_network_address: "1.1.1.1".to_string(),
            full_node_network_identity_pubkey: vec!(),
            full_node_network_address: "1.1.1.1".to_string(),
        };

        let mut file = File::create(&json_path.into()).unwrap();
        file.write(&val_configs.into())
            .expect("Could not write val_init.json");

    }
}

impl config::Override<MinerConfig> for GenesisCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
        Ok(config)
    }
}
