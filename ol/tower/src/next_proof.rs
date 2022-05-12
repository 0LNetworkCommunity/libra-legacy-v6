//! next proof

use anyhow::Error;
use diem_crypto::HashValue;
use ol::config::AppCfg;
use ol_types::vdf_difficulty::VDFDifficulty;

use crate::proof;
/// container for the next proof parameters to be fed to VDF prover.
pub struct NextProof {
  ///
  pub diff: VDFDifficulty,
  ///
  pub next_height: u64,
  ///
  pub preimage: Vec<u8>
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