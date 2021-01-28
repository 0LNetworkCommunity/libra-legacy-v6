//! `start` subcommand - example of how to write a subcommand

use crate::{
    account::ValConfigs,
    submit_tx::{eval_tx_status, get_params},
    keygen,
    node_keys::KeyScheme,
    config::MinerConfig,
    test_tx_swarm::get_params_from_swarm,
    submit_tx::submit_onboard_tx,
    prelude::*
};
use anyhow::Error;
use libra_types::waypoint::Waypoint;
use std::path::PathBuf;
use hex::decode;

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use move_core_types::account_address::AccountAddress;

/// `start` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct OnboardCmd {
    // Option for --waypoint, to set a specific waypoint besides genesis_waypoint which is found in key_store.json
    #[options(help = "Provide a waypoint for tx submission. Will otherwise use what is in key_store.json")]
    waypoint: String,
    // Path of the block_0.json to submit.
    #[options(help = "Path of the init.json to submit.")]
    file: PathBuf,
    #[options(help = "Run as test on local swarm")]
    swarm_path: PathBuf,
}

impl Runnable for OnboardCmd {
    /// Start the application.
    fn run(&self) {
        let miner_configs = app_config();
        let (_authkey, _account, wallet) = keygen::account_from_prompt();
        let keys = KeyScheme::new(wallet);

        let tx_params;
        if self.swarm_path.exists(){
            tx_params = get_params_from_swarm(self.swarm_path.clone()).unwrap();
        } else {
            let waypoint: Waypoint;
            let parsed_waypoint: Result<Waypoint, Error> = self.waypoint.parse();
            match parsed_waypoint {
                Ok(v) => {
                    println!("Using Waypoint from CLI args:\n{}", v);
                    waypoint = parsed_waypoint.unwrap();
                }
                Err(_e) => {
                    println!("Info: No waypoint parsed from command line args. Received: {:?}\n\
                    Using waypoint in miner.toml\n {:?}",
                    self.waypoint,
                    miner_configs.chain_info.base_waypoint);
                    waypoint = miner_configs.get_waypoint().unwrap();

                }
            }
            tx_params = get_params(keys, waypoint, &miner_configs);
        }

        let init_data = ValConfigs::get_init_data(&self.file).unwrap();
        
        match submit_onboard_tx(
            &tx_params,
            init_data.block_zero.preimage.to_owned(),
            init_data.block_zero.proof.to_owned(),
            init_data.ow_human_name.as_bytes().to_vec(),
            AccountAddress::from_hex_literal(&init_data.op_address).unwrap(),
            init_data.op_auth_key_prefix,
            init_data.op_consensus_pubkey,
            decode(init_data.op_validator_network_addresses).unwrap(),
            decode(init_data.op_fullnode_network_addresses).unwrap(),
            init_data.op_human_name.as_bytes().to_vec(),
        ) {
            Ok(res) => {
                match eval_tx_status(res.clone()) {
                    true => { 
                        status_ok!("Success", "Validator initialization committed. Exiting.");

                    },
                    false => {
                        status_err!("Init transaction failed with:");
                        println!("{:?}", res);
                    }
                }
            }
            Err(e) => {
                status_warn!(format!("Validator initialization error: {:?}", e));
            }
        }
    }
}

impl config::Override<MinerConfig> for OnboardCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
        Ok(config)
    }
}
