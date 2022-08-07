//! Miner resubmit backlog transactions module
#![forbid(unsafe_code)]

use std::io::BufReader;
use std::{fs::File, path::PathBuf};

use anyhow::{anyhow, bail, Error, Result};

use cli::diem_client::DiemClient;
use diem_logger::prelude::*;
use ol_types::block::VDFProof;
use ol_types::config::AppCfg;
use txs::submit_tx::{eval_tx_status, TxError};
use txs::tx_params::TxParams;

use crate::commit_proof::commit_proof_tx;
use crate::garbage_collection::gc_failed_proof;
use crate::proof::{get_highest_block, FILENAME};
use crate::{tower_errors, EPOCH_MINING_THRES_UPPER};

/// Submit a backlog of blocks that may have been mined while network is offline.
/// Likely not more than 1.
pub fn process_backlog(config: &AppCfg, tx_params: &TxParams) -> Result<(), TxError> {
    // Getting remote miner state
    // there may not be any onchain state.
    let (remote_height, proofs_in_epoch) = get_remote_tower_height(tx_params)?;

    info!("Remote tower height: {}", remote_height);
    info!("Proofs already submitted in epoch: {}", proofs_in_epoch);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);

    let (current_local_proof, _current_block_path) = get_highest_block(&blocks_dir)?;

    let current_proof_number = current_local_proof.height;
    // if let Some(current_proof_number) = current_local_proof {
    info!("Local tower height: {:?}", current_proof_number);
    if remote_height < 0 || current_proof_number > remote_height as u64 {
        let mut i = remote_height as u64 + 1;

        // use i64 for safety
        if !(proofs_in_epoch < EPOCH_MINING_THRES_UPPER as i64) {
            info!(
                "Backlog: Maximum number of proofs sent this epoch {}, exiting.",
                EPOCH_MINING_THRES_UPPER
            );
            return Err(anyhow!(
                "cannot submit more proofs than allowed in epoch, aborting backlog."
            )
            .into());
        }

        let remaining_in_epoch = if proofs_in_epoch > 0 {
            EPOCH_MINING_THRES_UPPER - proofs_in_epoch as u64
        } else {
            EPOCH_MINING_THRES_UPPER
        };
        let mut submitted_now = 1u64;

        info!("Backlog: resubmitting missing proofs. Remaining in epoch: {}, already submitted in this backlog: {}", remaining_in_epoch, submitted_now);

        while i <= current_proof_number && submitted_now <= remaining_in_epoch {
            let path = PathBuf::from(format!("{}/{}_{}.json", blocks_dir.display(), FILENAME, i));
            info!("submitting proof {}, in this backlog: {}", i, submitted_now);
            let file = File::open(&path).map_err(|e| Error::from(e))?;

            let reader = BufReader::new(file);
            let block: VDFProof = serde_json::from_reader(reader).map_err(|e| Error::from(e))?;

            let view = commit_proof_tx(&tx_params, block.clone())?;
            match eval_tx_status(view) {
                Ok(_) => {}
                Err(e) => {
                    warn!(
                        "WARN: could not fetch TX status, aborting. Message: {:?} ",
                        &e
                    );
                    // evaluate type of error and maybe garbage collect
                    match tower_errors::parse_error(&e) {
                        tower_errors::TowerError::WrongDifficulty => gc_failed_proof(config, path)?,
                        tower_errors::TowerError::Discontinuity => gc_failed_proof(config, path)?,
                        tower_errors::TowerError::Invalid => gc_failed_proof(config, path)?,
                        _ => {}
                    }
                    return Err(e);
                }
            };
            i = i + 1;
            submitted_now = submitted_now + 1;
        }
        // }
    }
    Ok(())
}

/// submit an exact proof height
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
    let (current_local_proof, _current_block_path) = get_highest_block(&blocks_dir)?;
    let current_proof_number = current_local_proof.height;
    // if let Some(current_proof_number) = current_local_proof {
    info!("Local tower height: {:?}", current_proof_number);

    if proof_to_submit > current_proof_number {
        warn!(
            "unable to submit proof - local tower height is smaller than {:?}",
            proof_to_submit
        );
        return Ok(());
    }

    if remote_height > 0 && proof_to_submit <= remote_height as u64 {
        warn!(
            "unable to submit proof - remote tower height is higher than or equal to {:?}",
            proof_to_submit
        );
        return Ok(());
    }

    info!("Backlog: submitting proof {:?}", proof_to_submit);

    let path = PathBuf::from(format!(
        "{}/{}_{}.json",
        blocks_dir.display(),
        FILENAME,
        proof_to_submit
    ));
    let file = File::open(&path).map_err(|e| Error::from(e))?;

    let reader = BufReader::new(file);
    let block: VDFProof = serde_json::from_reader(reader).map_err(|e| Error::from(e))?;

    let view = commit_proof_tx(&tx_params, block)?;
    match eval_tx_status(view) {
        Ok(_) => {}
        Err(e) => {
            warn!(
                "WARN: could not fetch TX status, aborting. Message: {:?} ",
                e
            );
            return Err(e);
        } // };
    }
    Ok(())
}

/// display the user's tower backlog
pub fn show_backlog(config: &AppCfg, tx_params: &TxParams) -> Result<(), TxError> {
    // Getting remote miner state
    // there may not be any onchain state.
    let (remote_height, _proofs_in_epoch) = get_remote_tower_height(tx_params)?;

    println!("Remote tower height: {}", remote_height);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_local_proof, _current_block_path) = get_highest_block(&blocks_dir)?;
    // if let Some(current_proof_number) = current_local_proof.height {
    println!("Local tower height: {:?}", current_local_proof.height);
    // } else {
    // println!("Local tower height: 0");
    // }
    Ok(())
}

/// returns remote tower height and current proofs in epoch
pub fn get_remote_tower_height(tx_params: &TxParams) -> Result<(i64, i64), Error> {
    let client = DiemClient::new(tx_params.url.clone(), tx_params.waypoint)?;
    info!(
        "Fetching remote tower height: {}, {}",
        tx_params.url.clone(),
        tx_params.owner_address.clone()
    );
    let tower_state = client.get_miner_state(&tx_params.owner_address);
    match tower_state {
        Ok(Some(s)) => {
            debug!("verified_tower_height: {:?}", s.verified_tower_height);
            debug!("latest_epoch_mining: {:?}", s.latest_epoch_mining);
            debug!("count_proofs_in_epoch: {:?}", s.count_proofs_in_epoch);
            debug!(
                "epochs_validating_and_mining: {:?}",
                s.epochs_validating_and_mining
            );
            debug!(
                "contiguous_epochs_validating_and_mining: {:?}",
                s.contiguous_epochs_validating_and_mining
            );
            debug!(
                "epochs_since_last_account_creation: {:?}",
                s.epochs_since_last_account_creation
            );
            debug!(
                "actual_count_proofs_in_epoch: {:?}",
                s.actual_count_proofs_in_epoch
            );

            return Ok((
                s.verified_tower_height as i64,
                s.actual_count_proofs_in_epoch as i64,
            ));
        }
        Ok(None) => {
            bail!("ERROR: user has no tower state on chain");
        }
        Err(e) => {
            println!(
                "ERROR: unable to get tower height from chain, message: {:?}",
                e
            );
            return Err(e);
        }
    }
}
