//! you can go your own way
//! you can call it another lonely day
//! you can go your own way

use std::path::PathBuf;
/// path to file fixture with a db backup
pub fn snapshot_path() -> PathBuf {
    use std::path::Path;
    let path = env!("CARGO_MANIFEST_DIR");
    Path::new(path)
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("ol/fixtures/rescue/state_backup/state_ver_76353076.a0ff")
        
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
}
