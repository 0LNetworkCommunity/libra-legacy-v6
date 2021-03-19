//! `trigger` functions

use crate::check;
use serde::{Serialize, Deserialize};
use std::{collections::HashSet, process::Command};

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
    const BINARY: &str = "libra-node";

    // TODO: Get node home from configs:
    let node_home = "/root/.0L/";
    // Start as validator or fullnode
    // Get the yaml file
    let config_file_name = match config_type {
        NodeType::Validator => {format!("{}validator.node.yaml", node_home)}
        NodeType::Fullnode => {format!("{}fullnode.node.yaml", node_home)}
    };

    // Stop any processes we may have started and detached from.
    kill_zombies(BINARY);

    let child = Command::new(BINARY)
                        .arg("--config")
                        .arg(config_file_name)
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();
    save_pid(BINARY, *pid);
    println!("--- Started new w/ pid: {}", pid);
}


/// Stop node, as validator
pub fn stop_node() {
    kill_zombies("libra-node");
}

/// Start Miner
pub fn start_miner() {}

/// Stop Miner
pub fn stop_miner() {}


