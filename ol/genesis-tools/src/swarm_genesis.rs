//! make genesis for swarm cases

use std::path::PathBuf;
use anyhow::Error;
use crate::{fork_genesis::save_genesis, generate_genesis::writeset_to_tx, read_archive::archive_into_swarm_writeset};

/// Make a recovery genesis blob
pub async fn make_swarm_genesis(
  genesis_blob_path: PathBuf,
  archive_path: PathBuf,
) -> Result<(), Error> {
  let ws = archive_into_swarm_writeset(archive_path).await?;
  let gen_tx = writeset_to_tx(ws);
  // save genesis
  save_genesis(gen_tx, genesis_blob_path)
}