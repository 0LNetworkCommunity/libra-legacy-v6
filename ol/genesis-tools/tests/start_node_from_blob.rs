use std::io::BufRead;
use std::io::BufReader;
use std::path::PathBuf;
use std::process::Command;
use std::process::Stdio;

#[test]
fn start_test_node() {
    use std::path::Path;
    std::env::set_var("RUST_LOG", "debug");
    let source_path = Path::new(env!("CARGO_MANIFEST_DIR"));
    let blob_path = blob_path();
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

fn blob_path() -> PathBuf {
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
