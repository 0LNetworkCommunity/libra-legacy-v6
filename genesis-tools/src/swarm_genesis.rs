//! make genesis for swarm cases

use crate::{fork_genesis::save_genesis, process_snapshot::archive_into_swarm_writeset};
use anyhow::Error;
use diem_types::{
    transaction::{ChangeSet, Transaction, WriteSetPayload},
    write_set::WriteSetMut,
};
use std::path::PathBuf;

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

/// WritesetMut into a genesis tx
fn writeset_to_tx(ws: WriteSetMut) -> Transaction {
    Transaction::GenesisTransaction(WriteSetPayload::Direct(ChangeSet::new(
        ws.freeze().unwrap(),
        vec![],
    )))
}
