//! `trigger` functions

use crate::{check, prelude::app_config};
use anyhow::Error;
use reqwest::Url;
use serde::{Serialize, Deserialize};
use std::{collections::HashSet, fs::{self, File}, process::{Command, Stdio}};

// const MINER_BINARY: &str = "miner";
// const NODE_BINARY: &str = "libra-node";
const MINER_BINARY_DEBUG: &str = "/root/libra/target/debug/miner";
const NODE_BINARY_DEBUG: &str = "/root/libra/target/debug/libra-node";
/// Process name and its set of PIDs ever spawned
#[derive(Serialize, Deserialize, Debug)]
struct Process {
    name: String,
    pids: HashSet<u32>,
}

/// Save PID
pub fn save_pid(name: &str, pid: u32) {
    // Handle empty case
    match check::DB_CACHE.get(name.as_bytes()) {
        Ok(Some(_value)) => { /* TODO */},
        Ok(None) => { 
            let process = Process { 
                name: name.to_owned(), pids: vec![pid].into_iter().collect() 
            };
            let serialized = serde_json::to_vec(&process).unwrap();
            check::DB_CACHE.put(name.as_bytes(), serialized).unwrap();
        },
        Err(e) => println!("RocksDB operational problem occured: {}", e),
    }    

    // Load, update and save
    let pids_loaded = check::DB_CACHE.get(name.as_bytes()).unwrap().unwrap();
    let mut process: Process = serde_json::de::from_slice(
        &pids_loaded
    ).unwrap();    
    process.pids.insert(pid);    
    let serialized = serde_json::to_vec(&process).unwrap();
    let _res = check::DB_CACHE.put(name.as_bytes(), serialized);
}

/// Kill all the processes that are running
pub fn kill_zombies(name: &str) {
    if check::DB_CACHE.get(name.as_bytes()).unwrap().is_none() {
        return;
    }

    let pids_loaded = check::DB_CACHE.get(name.as_bytes()).unwrap().unwrap();
    let process: Process = serde_json::de::from_slice(&pids_loaded).unwrap();

    println!("Killing zombie '{}' processes...", name);
    use nix::sys::signal::{self, Signal};
    for pid in process.pids.iter() {
        let _res = signal::kill(
            nix::unistd::Pid::from_raw(*pid as i32), Signal::SIGTERM
        );
    }
}

/// What kind of node are we starting
pub enum NodeType {
    /// Validator
    Validator,
    /// Fullnode
    Fullnode,
}

/// 
pub fn create_log_file(file_name: &str) -> File {
    let conf = app_config();
    let logs_dir = conf.workspace.node_home.join("logs/");
    dbg!(&logs_dir);
    fs::create_dir_all(&logs_dir).expect("could not create logs dir");
    let logs_file = logs_dir.join([file_name, ".log"].join(""));

    File::create(logs_file).expect("could not create log file")
}

/// Start Node, as fullnode
pub fn start_node(config_type: NodeType) -> Result<(), Error> {
    // Stop any processes we may have started and detached from.
    // Do not need to start

    // if is running do nothing
    if check::Check::new().node_running() {
        println!("node is already running. Exiting.");
        return Ok(())
    }
    // kill_zombies(NODE_BINARY_DEBUG);

    // Create log file, and pipe stdout/err    
    let outputs = create_log_file("node");
    let errors = outputs.try_clone().unwrap();

    // Start as validator or fullnode
    // Get the yaml file
    let conf = app_config();
    let node_home = conf.workspace.node_home.to_str().unwrap();
    let config_file_name = match config_type {
        NodeType::Validator => {format!("{}validator.node.yaml", node_home)}
        NodeType::Fullnode => {format!("{}fullnode.node.yaml", node_home)}
    };

    let child = Command::new(NODE_BINARY_DEBUG)
                        .arg("--config")
                        .arg(config_file_name)
                        .stdout(Stdio::from(outputs))
                        .stderr(Stdio::from(errors))
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();
    save_pid(NODE_BINARY_DEBUG, *pid);
    println!("Started new '{}' with PID: {}", NODE_BINARY_DEBUG, pid);
    Ok(())
}

/// Stop node, as validator
pub fn stop_node() {
    kill_zombies(NODE_BINARY_DEBUG);
}

/// Start Miner
pub fn start_miner() {
    // Stop any processes we may have started and detached from.
    // if is running do nothing
    if check::Check::new().miner_running() {
        println!("node is already running. Exiting.");
        return
    }

    // Create log file, and pipe stdout/err
    let outputs = create_log_file("miner");
    let errors = outputs.try_clone().unwrap();

    // if node is NOT synced, then should use a backup/upstream node
    // let url = choose_rpc_node().unwrap();
    let use_backup = if check::Check::node_is_synced() {"--backup-url"} else { "" };
    let child = Command::new(MINER_BINARY_DEBUG)
                        .arg("start")
                        .arg(use_backup)
                        .stdout(Stdio::from(outputs))
                        .stderr(Stdio::from(errors))
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();
    save_pid(MINER_BINARY_DEBUG, *pid);
    println!("Started new {} with PID: {}", MINER_BINARY_DEBUG, pid);
}

/// Stop Miner
pub fn stop_miner() {
    kill_zombies(MINER_BINARY_DEBUG);
}

/// Choose a node to connect for rpc, local or upstream
pub fn choose_rpc_node() -> Option<Url> {
    let conf = app_config().to_owned();

    // check the node is in sync
    // Note this assumes that we can connect to local and to a backup.
    if check::Check::node_is_synced() {
        // always choose local node if in sync
        return conf.chain_info.default_node
    } else {
        // otherwise use a backup
        // TODO: check all backups in vector to see which connects
        Some(conf.chain_info
            .upstream_nodes
            .unwrap()
            .into_iter()
            .next()
            .unwrap()
        )
    }
}

/// 
pub fn run_validator_wizard() -> bool {
    println!("Running validator wizard");
    // TODO: switch between debug mode?
    let mut miner = std::process::Command::new(MINER_BINARY_DEBUG)
                        .arg("val-wizard")
                        .arg("--keygen")
                        .spawn()
                        .expect(&format!("failed to start miner app"));

    let exit_code = miner.wait().expect("failed to wait on miner"); 
    assert!(exit_code.success());

    true
}