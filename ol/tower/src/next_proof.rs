//! next proof

use anyhow::{Error, bail};
use diem_crypto::HashValue;
use diem_types::{ol_vdf_difficulty::VDFDifficulty, account_address::AccountAddress};
use ol::{config::AppCfg, node::client::pick_client};

use crate::proof;
/// container for the next proof parameters to be fed to VDF prover.
pub struct NextProof {
    ///
    pub diff: VDFDifficulty,
    ///
    pub next_height: u64,
    ///
    pub preimage: Vec<u8>,
}
/// return the VDF difficulty expected and the next tower height
pub fn get_next_proof_params_from_local(config: &AppCfg) -> Result<NextProof, Error> {
    // get the location of this miner's blocks
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_local_block, _) = proof::get_highest_block(&blocks_dir)?;
    let diff = VDFDifficulty {
        difficulty: current_local_block.difficulty(),
        security: current_local_block.security.unwrap(),
    };
    Ok(NextProof {
        diff,
        next_height: current_local_block.height + 1,
        preimage: HashValue::sha3_256_of(&current_local_block.proof).to_vec(),
    })
}

/// query the chain for parameters to use in the next VDF proof.
/// includes global parameters for difficulty
/// and individual parameters like tower height and the preimage (previous proof hash)
pub fn get_next_proof_from_chain(
    config: &mut AppCfg
) -> Result<NextProof, Error> {
    let client = pick_client(None, config)?;

    // get the user's tower state from chain.
    let ts = client.get_account_state(config.profile.account)?.get_miner_state()?;

    if let Some(t) = ts {
        let a = client.get_account_state(AccountAddress::ZERO)?;
        if let Some(diff) = a.get_tower_params()? {
            return Ok(NextProof {
                diff,
                next_height: t.verified_tower_height + 1,
                preimage: t.previous_proof_hash,
            });
        }
        bail!("could not get this epoch's VDF params from chain.")
    }
    bail!("could not get tower state for accout: {}", config.profile.account)
}
