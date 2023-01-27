use std::{path::PathBuf, fs};
use ol_genesis_tools::fork_genesis::make_recovery_genesis_from_vec_legacy_recovery;
use ol_genesis_tools::recover::read_from_recovery_file;
use ol_genesis_tools::{process_snapshot::db_backup_into_recovery_struct, recover::save_recovery_file};

use std::io::BufRead;
use std::io::BufReader;
use std::process::Command;
use std::process::Stdio;

#[tokio::test]
async fn test_e2e() {

  //////// Export a JSON file from backup ////////
  let db_backup_path = snapshot_path();
  dbg!(&db_backup_path);
  assert!(db_backup_path.exists());

  let recovery_struct = db_backup_into_recovery_struct(
    &db_backup_path, 
    false
  ).await
  .expect("could not export backup into json file");

  let recover_json_output_path = db_backup_path.parent().unwrap().join("test_recovery.json");
  save_recovery_file(&recovery_struct, &recover_json_output_path.to_owned())
  .expect("ERROR: failed to create recovery from snapshot,");

  ///////////// Transform JSON file into Genesis Blob ////////
  let blob_output_path = recover_json_output_path.parent().unwrap().join("fork_genesis.blob");
  dbg!(&recover_json_output_path);
  dbg!(&blob_output_path);

  let recovery = read_from_recovery_file(&recover_json_output_path);

  make_recovery_genesis_from_vec_legacy_recovery(
      recovery,
      blob_output_path.clone(),
      true
  ).expect("ERROR: failed to create genesis from recovery file");
  
  assert!(blob_output_path.exists(), "file not created");
  
  start_test_node(blob_output_path.clone());

  fs::remove_file(blob_output_path)
    .expect("could not remove blob_output_pathfile");
  fs::remove_file(recover_json_output_path)
    .expect("could not remove recover_json_output_path file");
}

fn snapshot_path() -> PathBuf{
  use std::path::Path;
  let path = env!("CARGO_MANIFEST_DIR");
  Path::new(path)
    .parent()
    .unwrap()
    .parent()
    .unwrap()
    .join("ol/fixtures/rescue/state_backup/state_ver_76353076.a0ff").to_owned()

}

// TODO: This is duplicated in the start_node_from_blob
fn start_test_node(blob_path: PathBuf) {
    use std::path::Path;
    std::env::set_var("RUST_LOG", "debug");
    let source_path = Path::new(env!("CARGO_MANIFEST_DIR"));

    let mut swarm_cmd = Command::new("cargo");
    swarm_cmd.current_dir(&source_path.as_os_str());
    swarm_cmd
        .arg("run")
        .arg("-p")
        .arg("diem-node")
        .arg("--")
        .arg("--test")
        .arg("--genesis-modules")
        .arg(&blob_path.as_os_str());
    let mut cmd = swarm_cmd
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit()) // so we see error
        .spawn()
        .expect("could not start diem-node");

    let stdout = cmd.stdout.take().expect("no stdout");

    BufReader::new(stdout)
    .lines()
    .find(|e| {
        dbg!(&e);
        e.as_ref().unwrap().contains("==== 10")
    });
}
