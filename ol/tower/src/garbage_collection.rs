//! garbage collection

use std::path::PathBuf;

use diem_crypto::HashValue;
use ol::config::AppCfg;

use crate::{next_proof, proof};


/// check remaining proofs in backlog.
/// if they all fail, move the list to a trash file
pub fn find_first_discontinous_proof(cfg: AppCfg, swarm_path: Option<PathBuf>) -> anyhow::Result<Option<PathBuf>> {
  let block_dir = cfg.get_block_dir();
  let highest_local = proof::get_highest_block(&block_dir)?.0.height;
  // start from last known proof on chain.
  let p = next_proof::get_next_proof_from_chain(&mut cfg.clone(), swarm_path)?;

  if highest_local < p.next_height { return Ok(None) };
  // check if the next proof nonce that the chain expects has already been mined.

  let mut i = p.next_height;
  while i < highest_local {
    let (proof, file) = proof::find_proof_number(p.next_height, &block_dir)?;
        if p.preimage != HashValue::sha3_256_of(&proof.proof).to_vec() {
        return Ok(Some(file));
    }
    i += 1;
  }

  Ok(None)

}

/// if a proof can't be verified this epoch, the subsequent proofs will not be valid.
pub fn find_proofs_chain_with_deprecated_params() -> Option<Vec<PathBuf>> {
  // start from last known proof on chain.
  todo!()
}

/// take list of proofs and save in garbage file
pub fn put_in_trash() -> anyhow::Result<()> {
  todo!()
}