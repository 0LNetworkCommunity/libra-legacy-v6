//! Miner resubmit backlog transactions module
#![forbid(unsafe_code)]

use cli::{diem_client::DiemClient};
use ol_types::block::VDFProof;
use txs::submit_tx::{TxParams, eval_tx_status};
use std::{fs::File, path::PathBuf, thread, time};
use ol_types::config::AppCfg;
use crate::commit_proof::commit_proof_tx;
use std::io::BufReader;
use crate::proof::{parse_block_height, FILENAME};
use anyhow::{bail, Result, Error};
use diem_logger::prelude::*;

/// Submit a backlog of blocks that may have been mined while network is offline. 
/// Likely not more than 1. 
pub fn process_backlog(
    config: &AppCfg, tx_params: &TxParams, is_operator: bool, ignore_remote: bool
) -> Result<(), Error> {
    // Getting remote miner state
    //let remote_state = get_remote_state(tx_params)?;
    //let remote_height = remote_state.verified_tower_height;
    let mut remote_height = -1;

    if !ignore_remote {
        remote_height = get_remote_tower_height(tx_params).unwrap();
    }

    info!("Remote tower height: {}", remote_height);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);
    if let Some(current_block_number) = current_block_number {
        info!("Local tower height: {:?}", current_block_number);
        if i128::from(current_block_number) > remote_height {
            info!("Backlog: resubmitting missing proofs.");

            let mut i = remote_height + 1;
            while i <= current_block_number.into() {
                let path = PathBuf::from(
                    format!("{}/{}_{}.json", blocks_dir.display(), FILENAME, i)
                );
                info!("submitting proof {}", i);
                let file = File::open(&path)?;
                let reader = BufReader::new(file);
                let block: VDFProof = serde_json::from_reader(reader)?;
                let view = commit_proof_tx(
                    &tx_params, block, is_operator
                )?;
                match eval_tx_status(view) {
                    Ok(_) => {},
                    Err(e) => {
                      warn!("WARN: could not fetch TX status, continuing to next block in backlog after 30 seconds. Message: {:?} ", e);
                      thread::sleep(time::Duration::from_millis(30_000));
                    },
                };
                i = i + 1;
            }
        }
    }
    Ok(())
}

/// returns remote tower height
pub fn get_remote_tower_height(tx_params: &TxParams) -> Result<i128, Error> {
    let client = DiemClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();
    info!("Fetching remote tower height: {}, {}",
        tx_params.url.clone(), tx_params.owner_address.clone()
    );
    let remote_state = client.get_miner_state(&tx_params.owner_address);
    match remote_state {
        Ok( s ) => { match s {
            Some(remote_state) => {
                Ok(remote_state.verified_tower_height.into())
            },
            None => {
                static MSG: &str = "Info: Received response but no remote state found. Exiting.";
                info!("{}", MSG);
                bail!(MSG)
            }
        } },
        Err( _ ) => {
            // error info returned -> tower is not yet on chain, so the height is 0
            Ok(-1)
        },
    }
}

