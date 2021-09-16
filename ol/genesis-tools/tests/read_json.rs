use anyhow::Error;
use std::path::{Path, PathBuf};

#[test]
fn parse_snapshot() -> Result<(), Error> {
    let path = env!("CARGO_MANIFEST_DIR");
    let buf = Path::new(path)
        .parent()
        .unwrap()
        .join("fixtures/state-snapshot/194/state_ver_74694920.0889/state.manifest");
    let blobs = read_from_json(buf)?;
    let num = blobs.get("version").unwrap().as_i64();
    assert_eq!(num, Some(74694920));
    Ok(())
}

pub fn read_from_json(file_path: PathBuf) -> Result<serde_json::Value, Error> {
    let file = std::fs::File::open(file_path)?;
    let reader = std::io::BufReader::new(file);
    let json: serde_json::Value =
        serde_json::from_reader(reader).expect("Snapshot file should deserialize");
    Ok(json)
}
