//! process-snapshot

use crate::{
    read_snapshot::{self},
};
use anyhow::{Error, Result};
use backup_cli::backup_types::state_snapshot::manifest::StateSnapshotBackup;
use diem_types::{
    account_state_blob::AccountStateBlob,
    write_set::{WriteSetMut},
};


use ol_types::{legacy_recovery::{LegacyRecovery, accounts_into_recovery}};

use std::path::PathBuf;

/// take an archive file path and parse into a writeset
pub async fn db_backup_into_recovery_struct(
    archive_path: &PathBuf,
    is_legacy: bool,
) -> Result<Vec<LegacyRecovery>, Error> {
    let manifest_json = archive_path.join("state.manifest");

    let backup = read_snapshot::read_from_snaphot_manifest(&manifest_json)
        .unwrap_or_else(|_| panic!("cannot find snapshot file: {:?}", &manifest_json));

    let account_blobs = accounts_from_snapshot_backup(backup, archive_path).await?;
    let r = if is_legacy {
        println!("Parsing account state from legacy, Libra structs");
        todo!();
    } else {
        println!("Parsing account state from Diem structs");
        accounts_into_recovery(&account_blobs)?
    };

    Ok(r)
}

/// Tokio async parsing of state snapshot into blob
pub async fn accounts_from_snapshot_backup(
    manifest: StateSnapshotBackup,
    archive_path: &PathBuf,
) -> Result<Vec<AccountStateBlob>, Error> {
    // parse AccountStateBlob from chunks of the archive
    let mut account_state_blobs: Vec<AccountStateBlob> = Vec::new();
    for chunk in manifest.chunks {
        // dbg!(&archive_path);
        let blobs = read_snapshot::read_account_state_chunk(chunk.blobs, archive_path).await?;
        // println!("{:?}", blobs);
        for (_key, blob) in blobs {
            account_state_blobs.push(blob)
        }
    }

    Ok(account_state_blobs)
}


/// helper to merge writesets
pub fn merge_writeset(left: WriteSetMut, right: WriteSetMut) -> Result<WriteSetMut, Error> {
    let mut merge = left.get();
    merge.extend(right.get());
    Ok(WriteSetMut::new(merge))
}
