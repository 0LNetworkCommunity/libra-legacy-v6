//! Miner resubmit backlog transactions module
#![forbid(unsafe_code)]

use std::{fs::File, path::PathBuf};
use std::io::BufReader;
use anyhow::{anyhow, bail, Error, Result};

use diem_client::BlockingClient as DiemClient;
use diem_logger::prelude::*;
use ol_types::block::VDFProof;
use ol_types::config::AppCfg;
use txs::submit_tx::{eval_tx_status, TxError};
use txs::tx_params::TxParams;

use crate::commit_proof::commit_proof_tx;
use crate::EPOCH_MINING_THRES_UPPER;
use crate::proof::{FILENAME, parse_block_height};

/// Submit a backlog of blocks that may have been mined while network is offline.
/// Likely not more than 1.
pub fn process_backlog(
    config: &AppCfg,
    tx_params: &TxParams,
) -> Result<(), TxError> {
    // Getting remote miner state
    // there may not be any onchain state.
    let (remote_height, proofs_in_epoch) = get_remote_tower_height(tx_params)?;

    info!("Remote tower height: {}", remote_height);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);
    if let Some(current_proof_number) = current_block_number {
        info!("Local tower height: {:?}", current_proof_number);
        if remote_height < 0 || current_proof_number > remote_height as u64 {
            let mut i = remote_height as u64 + 1;

            // use i64 for safety
            if !(proofs_in_epoch < EPOCH_MINING_THRES_UPPER as i64) {
                info!(
                    "Backlog: Maximum number of proofs sent this epoch {}, exiting.",
                    EPOCH_MINING_THRES_UPPER
                );
                return Err(anyhow!("cannot submit more proofs than allowed in epoch, aborting backlog.").into());
            }

            info!("Backlog: resubmitting missing proofs.");

            let remaining_in_epoch = if proofs_in_epoch > 0 { EPOCH_MINING_THRES_UPPER - proofs_in_epoch as u64 } else { 0 };
            let mut submitted_now = 1u64;

            while i <= current_proof_number && submitted_now < remaining_in_epoch {
                let path =
                    PathBuf::from(format!("{}/{}_{}.json", blocks_dir.display(), FILENAME, i));
                info!("submitting proof {}, in this backlog: {}", i, submitted_now);
                let file = File::open(&path).map_err(|e| Error::from(e))?;

                let reader = BufReader::new(file);
                let block: VDFProof =
                    serde_json::from_reader(reader).map_err(|e| Error::from(e))?;

                let view = commit_proof_tx(&tx_params, block)?;
                match eval_tx_status(view) {
                    Ok(_) => {}
                    Err(e) => {
                        warn!(
                            "WARN: could not fetch TX status, aborting. Message: {:?} ",
                            e
                        );
                        return Err(e);
                    }
                };
                i = i + 1;
                submitted_now = submitted_now + 1;
            }
        }
    }
    Ok(())
}

///
pub fn submit_proof_by_number(
    config: &AppCfg,
    tx_params: &TxParams,
    proof_to_submit: u64,
) -> Result<(), TxError> {
    // Getting remote miner state
    // there may not be any onchain state.
    let (remote_height, _proofs_in_epoch) = get_remote_tower_height(tx_params)?;

    info!("Remote tower height: {}", remote_height);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);
    if let Some(current_proof_number) = current_block_number {
        info!("Local tower height: {:?}", current_proof_number);

        if proof_to_submit > current_proof_number {
            warn!("unable to submit proof - local tower height is smaller than {:?}", proof_to_submit);
            return Ok(());
        }

        if remote_height > 0 && proof_to_submit <= remote_height as u64 {
            warn!("unable to submit proof - remote tower height is higher than or equal to {:?}", proof_to_submit);
            return Ok(());
        }

        info!("Backlog: submitting proof {:?}", proof_to_submit);

        let path =
            PathBuf::from(format!("{}/{}_{}.json", blocks_dir.display(), FILENAME, proof_to_submit));
        let file = File::open(&path).map_err(|e| Error::from(e))?;

        let reader = BufReader::new(file);
        let block: VDFProof =
            serde_json::from_reader(reader).map_err(|e| Error::from(e))?;

        let view = commit_proof_tx(&tx_params, block)?;
        match eval_tx_status(view) {
            Ok(_) => {}
            Err(e) => {
                warn!(
                            "WARN: could not fetch TX status, aborting. Message: {:?} ",
                            e
                        );
                return Err(e);
            }
        };
    }
    Ok(())
}

///
pub fn show_backlog(
    config: &AppCfg,
    tx_params: &TxParams,
) -> Result<(), TxError> {
    // Getting remote miner state
    // there may not be any onchain state.
    let (remote_height, _proofs_in_epoch) = get_remote_tower_height(tx_params)?;

    println!("Remote tower height: {}", remote_height);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);
    if let Some(current_proof_number) = current_block_number {
        println!("Local tower height: {:?}", current_proof_number);
    } else {
        println!("Local tower height: 0");
    }
    Ok(())
}

/// returns remote tower height and current proofs in epoch
pub fn get_remote_tower_height(tx_params: &TxParams) -> Result<(i64, i64), Error> {
    let client = DiemClient::new(tx_params.url.clone());
    info!(
        "Fetching remote tower height: {}, {}",
        tx_params.url.clone(),
        tx_params.owner_address.clone()
    );
    let tower_state = client.get_miner_state(tx_params.owner_address);
    match tower_state {
        Ok(response) => match response.into_inner() { 
            Some(s) => Ok((
                s.verified_tower_height as i64,
                s.actual_count_proofs_in_epoch as i64
            )),
            None => bail!("ERROR: user has no tower state on chain"),
        }
        Err(e) => {
            println!(
                "ERROR: unable to get tower height from chain, message: {:?}", e
            );
            return Err(anyhow!(e));
        }
    }
}