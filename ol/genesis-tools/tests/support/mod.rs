//! When I was younger so much younger than today...
//! I never needed anybody's help in any way
//! -- Github Copilot

#[cfg(test)]
#[allow(dead_code)] // imported in tests

use std::path::PathBuf;
use diem_genesis_tool::{self, verify::compute_genesis};
use diem_temppath::TempPath;
use diem_types::waypoint::Waypoint;
use storage_interface::DbReaderWriter;

/// path to file fixture with a db backup
pub fn snapshot_path() -> PathBuf{
  use std::path::Path;
  let path = env!("CARGO_MANIFEST_DIR");
  Path::new(path)
    .parent()
    .unwrap()
    .parent()
    .unwrap()
    .join("ol/fixtures/rescue/state_backup/state_ver_76353076.a0ff").to_owned()

}

/// path to file fixture with JSON export of the data used in rescue genesis
pub fn json_path() -> PathBuf {
    use std::path::Path;
    let path = env!("CARGO_MANIFEST_DIR");
    Path::new(path)
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("ol/fixtures/rescue/sample_export_recovery.json")
        .to_owned()
}

/// path to file fixture with the rescue genesis blob
pub fn blob_path() -> PathBuf {
    use std::path::Path;
    let path = env!("CARGO_MANIFEST_DIR");
    Path::new(path)
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("ol/fixtures/rescue/sample_rescue_genesis.blob")
        .to_owned()
}


/// function that opens a temp database from a genesis blob.
pub fn read_db_and_compute_genesis(genesis_path: PathBuf) -> Result<(DbReaderWriter, Waypoint), anyhow::Error> {
    let db_path = TempPath::new();
    let (db_rw, expected_waypoint) = compute_genesis(&genesis_path, db_path.path())?;
    Ok((db_rw, expected_waypoint))
}