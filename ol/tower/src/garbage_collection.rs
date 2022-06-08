//! garbage collection

use std::path::PathBuf;


/// check remaining proofs in backlog.
/// if they all fail, move the list to a trash file
pub fn find_discontinous_proofs() -> Option<Vec<PathBuf>> {
  // start from last known proof on chain.
  todo!()
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