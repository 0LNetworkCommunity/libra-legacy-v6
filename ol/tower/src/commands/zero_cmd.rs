//! `zero` subcommand - example of how to write a subcommand

/// App-local prelude includes `app_reader()`/`app_writer()`/`app_config()`
/// accessors along with logging macros. Customize as you see fit.
use abscissa_core::{Command, Options, Runnable};
use anyhow::{anyhow, bail, Error, Result};
use diem_logger::prelude::*;
use ol_types::block::VDFProof;
use std::{fs::File, path::PathBuf};
use std::io::BufReader;
use txs::submit_tx::{eval_tx_status, TxError};
use txs::tx_params::TxParams;

use crate::{application::app_config, proof::write_genesis};
use crate::commit_proof::commit_proof_tx;
use crate::proof::{FILENAME, parse_block_height};

#[derive(Command, Debug, Options)]
pub struct ZeroCmd {}

impl Runnable for ZeroCmd {
    /// Start the application.
    fn run(&self) {
        let EntryPointTxsCmd {
            url,
            waypoint,
            swarm_path,
            swarm_persona,
            is_operator,
            use_first_url,
            ..
        } = entrypoint::get_args();

        // Setup logger
        let mut logger = Logger::new();
        logger
            .channel_size(1024)
            .is_async(true)
            .level(Level::Info)
            .read_env();
        logger.build();

        // config reading respects swarm setup
        // so also cfg.get_waypoint will return correct data
        let cfg = app_config().clone();

        let waypoint = if waypoint.is_none() {
            match cfg.get_waypoint(None) {
                Ok(w) => Some(w),
                Err(e) => {
                    status_err!("Cannot start without waypoint. Message: {:?}", e);
                    exit(-1);
                }
            }
        } else {
            waypoint
        };

        let tx_params = TxParams::new(
            cfg.clone(),
            url,
            waypoint,
            swarm_path,
            swarm_persona,
            TxType::Miner,
            is_operator,
            use_first_url,
            None,
        ).expect("could not get tx parameters");

        // Assumes the app has already been initialized.
        let miner_config = app_config().clone();
        match write_genesis(&miner_config) {
            Ok(_) => println!("Success. Proof zero mined"),
            Err(e) => {
                println!("ERROR: could not mine proof zero, message: {:?}", &e.to_string());
                exit(1);
            }
        }

        let mut blocks_dir = config.workspace.node_home.clone();
        blocks_dir.push(&config.workspace.block_dir);

        let path =
            PathBuf::from(format!("{}/{}_0.json", blocks_dir.display(), FILENAME));
        info!("submitting proof 0");
        let file = File::open(&path).map_err(|e| Error::from(e))?;

        let reader = BufReader::new(file);
        let block: VDFProof =
            serde_json::from_reader(reader).map_err(|e| Error::from(e))?;

        let view = commit_proof_tx(&tx_params, block, is_operator)?;
        match eval_tx_status(view) {
            Ok(_) => { info!("proof 0 submitted"); }
            Err(e) => {
                warn!(
                            "WARN: could not fetch TX status, aborting. Message: {:?} ",
                            e
                        );
                return Err(e);
            }
        };
    }
}
