//! Miner resubmit backlog transactions module
#![forbid(unsafe_code)]

use cli::{diem_client::DiemClient};
use ol_types::block::VDFProof;
use txs::submit_tx::eval_tx_status;
use txs::tx_params::TxParams;
use std::{fs::File, path::PathBuf, thread, time};
use ol_types::config::AppCfg;
use crate::commit_proof::commit_proof_tx;
use std::io::BufReader;
use crate::proof::{parse_block_height, FILENAME};
use anyhow::{bail, Result, Error};
use diem_logger::prelude::*;

/// max proofs that can be submitted in an epoch
// TODO: make this a query to chain.
pub const MAX_PROOFS_PER_EPOCH: u64 = 72;

/// Submit a backlog of blocks that may have been mined while network is offline. 
/// Likely not more than 1. 
pub fn process_backlog(
    config: &AppCfg, tx_params: &TxParams, is_operator: bool
) -> Result<(), Error> {
    // Getting remote miner state
    //let remote_state = get_remote_state(tx_params)?;
    //let remote_height = remote_state.verified_tower_height;
    let (remote_height, proofs_in_epoch) = get_remote_tower_height(tx_params).unwrap();

    info!("Remote tower height: {}", remote_height);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);
    if let Some(current_proof_number) = current_block_number {
        info!("Local tower height: {:?}", current_proof_number);
        if current_proof_number > remote_height {

            let mut i = remote_height + 1;

            // use i64 for safety
            if !(proofs_in_epoch < MAX_PROOFS_PER_EPOCH) {
              info!("Backlog: Maximum number of proofs sent this epoch {}, exiting.", MAX_PROOFS_PER_EPOCH);
              return Ok(())
            }

            info!("Backlog: resubmitting missing proofs.");

            let remaining_in_epoch = MAX_PROOFS_PER_EPOCH - proofs_in_epoch;
            let mut submitted_now = 1u64;

            while i <= current_proof_number.into() && submitted_now < remaining_in_epoch {
                let path = PathBuf::from(
                    format!("{}/{}_{}.json", blocks_dir.display(), FILENAME, i)
                );
                info!("submitting proof {}, in this backlog: {}", i, submitted_now);
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
                submitted_now = submitted_now + 1;
            }
        }
    }
    Ok(())
}

/// returns remote tower height and current proofs in epoch
pub fn get_remote_tower_height(tx_params: &TxParams) -> Result<(u64, u64), Error> {
    let client = DiemClient::new(tx_params.url.clone(), tx_params.waypoint).unwrap();
    info!("Fetching remote tower height: {}, {}",
        tx_params.url.clone(), tx_params.owner_address.clone()
    );
    let tower_state = client.get_miner_state(&tx_params.owner_address);
    match tower_state {
        Ok(Some(s)) => Ok((s.verified_tower_height, s.actual_count_proofs_in_epoch)),     
        _ => bail!("Info: Received response but no remote state found. Exiting.")
    }
}