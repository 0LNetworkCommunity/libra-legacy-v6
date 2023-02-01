use std::io::BufRead;
use std::io::BufReader;
use std::path::PathBuf;
use std::process::Command;
use std::process::Stdio;
use diem_json_rpc::views::AccountView;
use diem_types::account_address::AccountAddress;
// use move_core_types::move_resource::MoveResource;

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

    // Listen to stdout and wait until the tenth block is reported.
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



fn post_node_json(a: AccountAddress) -> anyhow::Result<AccountView>{
  let url = format!("http://0.0.0.0:8080/v1");

  let query = serde_json::json!( {
    "jsonrpc":"2.0",
    "method":"get_account",
    "params":[&a.to_string()],
    "id":1
  });


  let client = reqwest::blocking::Client::new();
  let res: serde_json::Value = client.post(url)
    .json(&query)
    .send()?
    .json()?;

  let body = res["result"].to_owned();
  dbg!(&body);
  let view = serde_json::from_value(body)?;
  Ok(view)
}

#[test]
fn meta_test_node() {
  // NOTE: start cargo r -p diem-node -- --test
  let r = post_node_json(AccountAddress::ZERO);
  dbg!(&r);
}
