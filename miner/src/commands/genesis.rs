//! `start` subcommand - example of how to write a subcommand

use crate::{block::Block, account::ValConfigs, node_keys::KeyScheme, block::build_block};
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

        build_block::mine_genesis(&miner_configs);

        // Create val_init.json file.
        let keys = KeyScheme::new_from_mnemonic(mnemonic_string);

        let mut json_path = PathBuf::from(&miner_configs.workspace.node_home);
        json_path.push("val_init.json");

        // Read from block_0.json to confirm it's properly formed.
        let mut block_json = PathBuf::from(&miner_configs.workspace.node_home);
        block_json.push("blocks/block_0.json");
        println!("load block_0 from {:?}", &block_json);
        let f = File::open(block_json).expect("Could not open block_0 files");
        let block: Block = serde_json::from_reader(f).expect("Can not read block_0.json");

        let owner_address = keys.child_0_owner.get_address().to_string();
        // let op_authkey = keys.child_1_operator.get_address();
        let val_configs = ValConfigs {
            /// Block zero of the onboarded miner
            block_zero: block,
            ow_human_name: owner_address.clone(),
            op_address: format!("0x{}", keys.child_1_operator.get_address().to_string()),
            op_auth_key_prefix: keys.child_1_operator.get_authentication_key().prefix().to_vec(),
            op_consensus_pubkey: keys.child_4_consensus.get_public().to_bytes().into(),
            op_validator_network_addresses: miner_configs.profile.ip.to_string(),
            op_fullnode_network_addresses: miner_configs.profile.ip.to_string(),
            op_human_name: format!("{}-oper", owner_address),
        };
        
        dbg!(&val_configs);

        let mut file = File::create(json_path.as_path()).unwrap();
        let buf = serde_json::to_string(&val_configs ).expect("Config should be export to json");
        file.write(&buf.as_bytes() )
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
