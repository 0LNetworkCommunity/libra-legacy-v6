//! read-archive

use anyhow::Result;
use backup_cli::{
    backup_types::state_snapshot::manifest::StateSnapshotBackup,
    storage::{FileHandle, FileHandleRef},
    utils::read_record_bytes::ReadRecordBytes,
};
use diem_crypto::HashValue;
use diem_types::account_state_blob::AccountStateBlob;
use std::path::PathBuf;
use tokio::{fs::OpenOptions, io::AsyncRead};

////// SNAPSHOT FILE IO //////
/// read snapshot manifest file into object
pub fn read_from_json(path: &PathBuf) -> Result<StateSnapshotBackup> {
    let config = std::fs::read_to_string(path)?;
    let map: StateSnapshotBackup = serde_json::from_str(&config)?;
    Ok(map)
}

/// parse each chunk of a state snapshot manifest
pub async fn read_account_state_chunk(
    file_handle: FileHandle,
    archive_path: &PathBuf,
) -> Result<Vec<(HashValue, AccountStateBlob)>> {
    let full_handle = archive_path.parent().unwrap().join(file_handle);
    let handle_str = full_handle.to_str().unwrap();
    let mut file = open_for_read(handle_str).await?;
    let mut chunk = vec![];

    while let Some(record_bytes) = file.read_record_bytes().await? {
        chunk.push(lcs::from_bytes(&record_bytes)?);
    }
    Ok(chunk)
}

async fn open_for_read(file_handle: &FileHandleRef) -> Result<Box<dyn AsyncRead + Send + Unpin>> {
    let file = OpenOptions::new().read(true).open(file_handle).await?;
    Ok(Box::new(file))
}
