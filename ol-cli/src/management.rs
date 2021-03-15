//! `trigger` functions

use serde::{Serialize, Deserialize};
use std::process::Command;
use crate::check;

#[derive(Serialize, Deserialize, Debug)]
struct Process {
    name: String,
    pids: Vec<u32>,
}

/// Save PID
pub fn save_pid(name: &str, pid: u32) {

    let db = check::cache_handle();
    
    // TODO: Handle the first pass - no "pids"
    // if !db.is_empty() {
        // let process = Process { name: name.to_owned(), pids: vec![] };
        // let serialized = serde_json::to_vec(&process).unwrap();
        // db.put(b"pids", serialized).unwrap();
    // }

    // Load
    let pids_loaded = db.get(b"pids").unwrap().unwrap();    
    let mut process: Process = serde_json::de::from_slice(
        &pids_loaded.to_vec()
    ).unwrap();
    // println!("--- Loaded: {:?}", &p);

    // Update & Save
    if !process.pids.contains(&pid) {
        process.pids.push(pid);
    }
    let serialized = serde_json::to_vec(&process).unwrap();
    let _res = db.put(b"pids", serialized);
    println!("--- Saved: {:?}", &process);
}

/// Kill all the processes that are running
pub fn kill_zombies(_name: &str) {
    let db = check::cache_handle();
    // TODO: 
    // if db.is_empty() { return; }

    let pids_loaded = db.get(b"pids").unwrap().unwrap().to_vec();
    let process: Process = serde_json::de::from_slice(&pids_loaded).unwrap();
    println!("--- kz: Loaded: {:?}", &process);

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
    const BINARY: &str = "cargo r -p libra-node -- ";

    // TODO: Get node home from configs:
    let node_home = "/root/.0L/";
    // Start as validator or fullnode
    // Get the yaml file
    let config_file_name = match config_type {
        NodeType::Validator => {format!("{}validator.node.yaml", node_home)}
        NodeType::Fullnode => {format!("{}fullnode.node.yaml", node_home)}
    };

    dbg!(&config_file_name);
    // Stop any processes we may have started and detached from.
    kill_zombies(BINARY);

    let mut child = Command::new(BINARY)
                        .arg("--config")
                        .arg(config_file_name)
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();
    println!("pid: {}", pid);
    save_pid(BINARY, *pid);
}


/// Stop node, as validator
pub fn stop_node() {
    kill_zombies("libra-node");
}

/// Start Miner
pub fn start_miner() {}

/// Stop Miner
pub fn stop_miner() {}


