//! This module contains utilities for creating a temporary database from a genesis blob.
use diem_genesis_tool::{self, verify::compute_genesis};
use diem_temppath::TempPath;
use diem_types::waypoint::Waypoint;
use std::path::PathBuf;
use storage_interface::DbReaderWriter;

/// function that opens a temp database from a genesis blob.
pub fn read_db_and_compute_genesis(
    genesis_path: PathBuf,
) -> Result<(DbReaderWriter, Waypoint), anyhow::Error> {
    let db_path = TempPath::new();
    let (db_rw, expected_waypoint) = compute_genesis(&genesis_path, db_path.path())?;
    Ok((db_rw, expected_waypoint))
}
