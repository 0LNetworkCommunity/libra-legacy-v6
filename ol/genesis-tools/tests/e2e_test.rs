mod support;

use diem_types::account_address::AccountAddress;
use ol_genesis_tools::fork_genesis::make_recovery_genesis_from_vec_legacy_recovery;
use ol_genesis_tools::recover::read_from_recovery_file;
use ol_genesis_tools::{
    process_snapshot::db_backup_into_recovery_struct, recover::save_recovery_file,
};
use std::{fs, path::PathBuf};
use support::path_utils::snapshot_path;

use diem_json_rpc::views::AccountView;
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

    let recovery_struct = db_backup_into_recovery_struct(&db_backup_path, false)
        .await
        .expect("could not export backup into json file");

    let recover_json_output_path = db_backup_path.parent().unwrap().join("test_recovery.json");
    save_recovery_file(&recovery_struct, &recover_json_output_path.to_owned())
        .expect("ERROR: failed to create recovery from snapshot,");

    ///////////// Transform JSON file into Genesis Blob ////////
    let blob_output_path = recover_json_output_path
        .parent()
        .unwrap()
        .join("fork_genesis.blob");
    dbg!(&recover_json_output_path);
    dbg!(&blob_output_path);

    let recovery = read_from_recovery_file(&recover_json_output_path);

    make_recovery_genesis_from_vec_legacy_recovery(
      recovery,
      vec![], // Todo: add validators
      blob_output_path.clone(), 
      true
    )
        .expect("ERROR: failed to create genesis from recovery file");

    assert!(blob_output_path.exists(), "file not created");

    start_test_node(blob_output_path.clone());

    let root: AccountView = post_node_json(AccountAddress::ZERO).await.unwrap();
    dbg!(&root);
    assert!(
        root.balances[0].amount == 10000000,
        "root address has wrong balance"
    );

    // check a validators account
    let user = AccountAddress::from_hex_literal("0xD0D62AE27A4E84B559DA089A1B15A79F").unwrap();
    let _acc = post_node_json(user).await;
    assert!(
        root.balances[0].amount == 10214368210584,
        "validator address has wrong balance"
    );

    // check an end-user account
    let user = AccountAddress::from_hex_literal("0xF43F043F49FA3ACB7C5F98DBD2DA997E").unwrap();
    let acc = post_node_json(user).await;
    assert!(
        root.balances[0].amount == 968472,
        "end user address has wrong balance"
    );

    dbg!(&acc);

    fs::remove_file(blob_output_path).expect("could not remove blob_output_pathfile");
    fs::remove_file(recover_json_output_path)
        .expect("could not remove recover_json_output_path file");
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

    BufReader::new(stdout).lines().find(|e| {
        dbg!(&e);
        e.as_ref().unwrap().contains("==== 10")
    });
}

async fn post_node_json(a: AccountAddress) -> anyhow::Result<AccountView> {
    let url = format!("http://0.0.0.0:8080/v1");

    let query = serde_json::json!( {
      "jsonrpc":"2.0",
      "method":"get_account",
      "params":[&a.to_string()],
      "id":1
    });

    let client = reqwest::Client::new();
    let res: serde_json::Value = client.post(url).json(&query).send().await?.json().await?;

    let body = res["result"].to_owned();
    dbg!(&body);
    let view = serde_json::from_value(body)?;
    Ok(view)
}
