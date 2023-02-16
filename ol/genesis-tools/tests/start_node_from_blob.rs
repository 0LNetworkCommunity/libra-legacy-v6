mod support;
use diem_config::config::NodeConfig;
use diem_config::config::PersistableConfig;
use diem_config::config::WaypointConfig;
use diem_json_rpc::views::AccountView;
use diem_types::account_address::AccountAddress;
use ol_genesis_tools::db_utils::read_db_and_compute_genesis;
use std::fs;
use std::io::BufRead;
use std::io::BufReader;
use std::net::SocketAddr;
use std::path::PathBuf;
use std::process::Command;
use std::process::Stdio;
use support::path_utils;
use ol_smoke_tests::ol_test_config_builder::test_config;

#[test]
fn start_test_node() {
    use std::path::Path;
    std::env::set_var("RUST_LOG", "debug");
    let source_path = Path::new(env!("CARGO_MANIFEST_DIR"));
    // let blob_path = path_utils::blob_path();

    let (_cfg, cfg_path) = get_test_configs().unwrap();
    let mut process = Command::new("cargo");
    process.current_dir(&source_path.as_os_str());
    process
        .arg("run")
        .arg("-p")
        .arg("diem-node")
        .arg("--")
        .arg("-f")
        .arg(cfg_path.to_str().unwrap());
    // .arg(&blob_path.as_os_str());
    let mut cmd = process
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit()) // so we see error
        .spawn()
        .expect("could not start diem-node");

    let stdout = cmd.stdout.take().expect("no stdout");

    // Listen to stdout and wait until the tenth block is reported.
    BufReader::new(stdout).lines().find(|e| {
        dbg!(&e);
        e.as_ref().unwrap().contains("==== 1")
    });

    let val: AccountAddress = "ADCB1D42A46292AE89E938BD982F2867".parse().unwrap();
    post_node_json(val).unwrap();
    
    cmd.kill().unwrap();
    clean_up();
}

fn post_node_json(a: AccountAddress) -> anyhow::Result<AccountView> {
    let url = "http://0.0.0.0:8080/v1".to_string();

    let query = serde_json::json!( {
      "jsonrpc":"2.0",
      "method":"get_account",
      "params":[&a.to_string()],
      "id":1
    });

    let client = reqwest::blocking::Client::new();
    let res: serde_json::Value = client.post(url).json(&query).send()?.json()?;

    let body = res["result"].to_owned();
    let view = serde_json::from_value(body)?;
    Ok(view)
}


fn get_test_configs() -> Result<(NodeConfig, PathBuf), anyhow::Error> {
    let gen_blob = path_utils::blob_path();
    // dbg!(&gen_blob);
    let (_db, wp) = read_db_and_compute_genesis(gen_blob.clone()).expect("parse genesis.blob");
    // dbg!(&wp);

    let (mut cfg, _) = test_config(true);
    let save_path = gen_blob
        
        .parent()
        .unwrap()
        .join("testing.validator.node.yaml");

    cfg.execution.genesis_file_location = gen_blob.clone();
    cfg.base.waypoint = WaypointConfig::FromConfig(wp);
    cfg.set_data_dir(gen_blob.parent().unwrap().join("test_data"));
    cfg.json_rpc.address = SocketAddr::from(([0, 0, 0, 0], 8080));
    if let Some(mut t) = cfg.consensus.safety_rules.test {
        t.waypoint = Some(wp);
        cfg.consensus.safety_rules.test = Some(t);
    }
    cfg.save_config(save_path.clone())?;

    Ok((cfg, save_path))
}


fn clean_up() {
    let save_path = path_utils::blob_path()
        
        .parent()
        .unwrap()
        .join("testing.validator.node.yaml");

    let data_dir = path_utils::blob_path().parent().unwrap().join("test_data");
    fs::remove_file(save_path).unwrap();
    fs::remove_dir_all(data_dir).unwrap();
}
