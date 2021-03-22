//! `trigger` functions

use crate::{check, prelude::app_config};
use reqwest::Url;
use serde::{Serialize, Deserialize};
use std::{collections::HashSet, fs::{self, File}, process::{Command, Stdio}};

const NODE_BINARY: &str = "libra-node";
const MINER_BINARY: &str = "miner";

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
    println!("--- Saved: {:?}, pids.len: {}", &process, process.pids.len());
}

/// Kill all the processes that are running
pub fn kill_zombies(name: &str) {
    if check::DB_CACHE.get(name.as_bytes()).unwrap().is_none() {
        return;
    }

    let pids_loaded = check::DB_CACHE.get(name.as_bytes()).unwrap().unwrap();
    let process: Process = serde_json::de::from_slice(&pids_loaded).unwrap();
    println!("--- kz: Loaded: {:?}, pids.len: {}", &process, process.pids.len());

    use nix::sys::signal::{self, Signal};
    for pid in process.pids.iter() {
        let res = signal::kill(
            nix::unistd::Pid::from_raw(*pid as i32), Signal::SIGTERM
        );
        println!("--- kz: Killing pid {}, result: {:?}", pid, res);
    }        
}
/// What kind of node are we starting
pub enum NodeType {
    /// Validator
    Validator,
    /// Fullnode
    Fullnode,
}

/// Start Node, as fullnode
pub fn start_node(config_type: NodeType) {
    // Stop any processes we may have started and detached from.
    kill_zombies(NODE_BINARY);

    // create log file, and pipe stdout/err
    let conf = app_config().to_owned();
    let logs_dir = conf.workspace.node_home.join("logs/");
    dbg!(&logs_dir);
    fs::create_dir_all(&logs_dir).expect("could not create logs dir");
    let logs_file = logs_dir.join("node.log");
    let outputs = File::create(logs_file).expect("could not create node log file");
    let errors = outputs.try_clone().unwrap();

    // Start as validator or fullnode
    // Get the yaml file
    let config_file_name = match config_type {
        NodeType::Validator => {format!("{}validator.node.yaml", conf.workspace.node_home.to_str().unwrap())}
        NodeType::Fullnode => {format!("{}fullnode.node.yaml", conf.workspace.node_home.to_str().unwrap())}
    };





    let child = Command::new(NODE_BINARY)
                        .arg("--config")
                        .arg(config_file_name)
                        .stdout(Stdio::from(outputs))
                        .stderr(Stdio::from(errors))
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();
    save_pid(NODE_BINARY, *pid);
    println!("--- Started new {} w/ pid: {}", NODE_BINARY, pid);
}


/// Stop node, as validator
pub fn stop_node() {
    kill_zombies(NODE_BINARY);
}

/// Start Miner
pub fn start_miner() {
    // Stop any processes we may have started and detached from.
    kill_zombies(MINER_BINARY);

        // create log file, and pipe stdout/err
    let conf = app_config().to_owned();
    let logs_dir = conf.workspace.node_home.join("logs/");
    dbg!(&logs_dir);
    fs::create_dir_all(&logs_dir).expect("could not create logs dir");
    let logs_file = logs_dir.join("miner.log");
    let outputs = File::create(logs_file).expect("could not create miner log file");
    let errors = outputs.try_clone().unwrap();

    // if node is NOT synced, then should use a backup/upstream node
    // let url = choose_rpc_node().unwrap();
    let use_backup = if check::Check::node_is_synced() {"--backup-url"} else { "" };
    let child = Command::new(MINER_BINARY)
                        .arg("start")
                        .arg(use_backup)
                        .stdout(Stdio::from(outputs))
                        .stderr(Stdio::from(errors))
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();
    save_pid(MINER_BINARY, *pid);
    println!("--- Started new {} w/ pid: {}", MINER_BINARY, pid);
}

/// Stop Miner
pub fn stop_miner() {
    kill_zombies(MINER_BINARY);
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
            .backup_nodes
            .unwrap()
            .into_iter()
            .next()
            .unwrap()
        )
    }
}

pub fn run_validator_wizard() -> bool {
    println!("Running validator wizard");
    // TODO: switch between debug mode?
    // let miner_path = "miner";
    let mut miner = std::process::Command::new("miner")
                        .arg("val-wizard")
                        .arg("--keygen")
                        .spawn()
                        .expect(&format!("failed to start miner app"));

    let exit_code = miner.wait().expect("failed to wait on miner"); 
    assert!(exit_code.success());

    true
}