//! Miner resubmit backlog transactions module
#![forbid(unsafe_code)]

use crate::commit_proof::commit_proof_tx;
use crate::proof::{parse_block_height, FILENAME};
use anyhow::{anyhow, bail, Error, Result};
use cli::diem_client::DiemClient;
use diem_logger::prelude::*;
use ol_types::block::VDFProof;
use ol_types::config::AppCfg;
use std::io::BufReader;
use std::{fs::File, path::PathBuf};
use txs::submit_tx::{eval_tx_status, TxError};
use txs::tx_params::TxParams;
use crate::EPOCH_MINING_THRES_UPPER;

/// Submit a backlog of blocks that may have been mined while network is offline.
/// Likely not more than 1.
pub fn process_backlog(
    config: &AppCfg,
    tx_params: &TxParams,
    is_operator: bool,
    omit_remote_check: bool,
) -> Result<(), TxError> {
    // Getting remote miner state
    // there may not be any onchain state.
    let mut remote_height = 0u64;
    let mut proofs_in_epoch = 0u64;

    if !omit_remote_check {
        let (rem_remote_height, rem_proofs_in_epoch) = get_remote_tower_height(tx_params).unwrap();

        remote_height = rem_remote_height;
        proofs_in_epoch = rem_proofs_in_epoch;
    }
    else {
        info!("ommitting remote tower height check");
    }

    info!("Remote tower height: {}", remote_height);
    // Getting local state height
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);
    if let Some(current_proof_number) = current_block_number {
        info!("Local tower height: {:?}", current_proof_number);
        if current_proof_number > remote_height || omit_remote_check {
            let mut i = remote_height + 1;

            if omit_remote_check {
                i = 0
            }

            // use i64 for safety
            if !(proofs_in_epoch < EPOCH_MINING_THRES_UPPER) {
                info!(
                    "Backlog: Maximum number of proofs sent this epoch {}, exiting.",
                    EPOCH_MINING_THRES_UPPER
                );
                return Err(anyhow!("cannot submit more proofs than allowed in epoch, aborting backlog.").into());
            }

            info!("Backlog: resubmitting missing proofs.");

            let remaining_in_epoch = EPOCH_MINING_THRES_UPPER - proofs_in_epoch;
            let mut submitted_now = 1u64;

            while i <= current_proof_number.into() && submitted_now < remaining_in_epoch {
                let path =
                    PathBuf::from(format!("{}/{}_{}.json", blocks_dir.display(), FILENAME, i));
                info!("submitting proof {}, in this backlog: {}", i, submitted_now);
                let file = File::open(&path).map_err(|e| Error::from(e))?;

                let reader = BufReader::new(file);
                let block: VDFProof =
                    serde_json::from_reader(reader).map_err(|e| Error::from(e))?;

                let view = commit_proof_tx(&tx_params, block, is_operator)?;
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

/// returns remote tower height and current proofs in epoch
pub fn get_remote_tower_height(tx_params: &TxParams) -> Result<(u64, u64), Error> {
    let client = DiemClient::new(tx_params.url.clone(), tx_params.waypoint)?;
    info!(
        "Fetching remote tower height: {}, {}",
        tx_params.url.clone(),
        tx_params.owner_address.clone()
    );
    let tower_state = client.get_miner_state(&tx_params.owner_address);
    match tower_state {
        Ok(Some(s)) => Ok((s.verified_tower_height, s.actual_count_proofs_in_epoch)),
        _ => bail!("Info: Received response but no remote state found. Exiting."),
    }
}
