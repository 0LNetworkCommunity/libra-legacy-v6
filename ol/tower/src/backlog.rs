//! Miner resubmit backlog transactions module
#![forbid(unsafe_code)]

use crate::commit_proof::commit_proof_tx;
use crate::proof::{parse_block_height, FILENAME};
use anyhow::{bail, Error, Result};
use cli::diem_client::DiemClient;
use diem_logger::prelude::*;
use ol_types::block::VDFProof;
use ol_types::config::AppCfg;
use std::io::BufReader;
use std::{fs::File, path::PathBuf};
use txs::epoch::get_epoch;
use txs::submit_tx::{eval_tx_status, TxParams};

// only 72 proofs are allowed per epoch
const MAX_PROOFS_PER_EPOCH: i64 = 72;
/// Submit a backlog of blocks that may have been mined while network is offline.
/// Likely not more than 1.
pub fn process_backlog(
    config: &AppCfg,
    tx_params: &TxParams,
    is_operator: bool,
) -> Result<(), Error> {
    // Getting remote miner state
    // Getting remote miner state
    let remote_state = get_remote_state(tx_params)?;
    let remote_height = remote_state.verified_tower_height;
    let mut proofs_in_epoch: i64 = 0;
    let current_epoch = get_epoch(tx_params);
    if remote_state.latest_epoch_mining == current_epoch {
        proofs_in_epoch = remote_state.count_proofs_in_epoch as i64;
    }
    let remaining_proofs_in_epoch: i64 = max(0, MAX_PROOFS_PER_EPOCH - proofs_in_epoch);
    println!(
        "Remote tower height: {}, proofs_in_epoch: {},
        remaining_proofs_in_epoch: {}, current_epoch: {}",
        remote_height, proofs_in_epoch, remaining_proofs_in_epoch, current_epoch
    );

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
            let mut j = 0; // number of proofs submitted
            while i <= current_block_number.into() && j < remaining_proofs_in_epoch {
                let path =
                    PathBuf::from(format!("{}/{}_{}.json", blocks_dir.display(), FILENAME, i));
                info!("submitting proof {}", i);
                let file = File::open(&path)?;
                let reader = BufReader::new(file);
                let block: VDFProof = serde_json::from_reader(reader)?;
                let view = commit_proof_tx(&tx_params, block, is_operator)?;
                match eval_tx_status(view) {
                    Ok(_) => {}
                    Err(e) => {
                        warn!("WARN: could not fetch TX status, continuing to next block in backlog after 30 seconds. Message: {:?} ", e);
                        break;
                    }
                };
                i = i + 1;
                j = j + 1;
            }
        }
    }
    Ok(())
}

/// returns remote tower state
pub fn get_remote_state(tx_params: &TxParams) -> Result<TowerStateResourceView, Error> {
    let client = DiemClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();
    println!(
        "Fetching remote tower state: {}, {}",
        tx_params.url.clone(),
        tx_params.owner_address.clone()
    );
    let remote_state = client.get_miner_state(&tx_params.owner_address);
    match remote_state {
        Ok(s) => match s {
            Some(remote_state) => Ok(remote_state),
            None => {
                println!("Info: Received response but no remote state found. Exiting.");
                bail!("Error getting resourcev view")
            }
        },
        Err(_) => {
            // error info returned -> tower is not yet on chain, so the height is 0
            bail!("Account is not yet on chain")
        }
    }
}
