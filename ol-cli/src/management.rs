//! `management` functions

use crate::{cache::DB_CACHE, node_health, prelude::app_config, entrypoint};
use anyhow::Error;
use once_cell::sync::Lazy;
use reqwest::Url;
use serde::{Deserialize, Serialize};
use std::{
    collections::HashSet,
    env,
    fs::{self, File},
    process::{Command, Stdio},
};

const BINARY_NODE: &str = "libra-node";
const BINARY_MINER: &str = "miner";

/// Process name and its set of PIDs ever spawned
#[derive(Serialize, Deserialize, Debug)]
struct Process {
    name: String,
    pids: HashSet<u32>,
}

/// Check if we are in prod mode
pub static IS_PROD: Lazy<bool> = Lazy::new(|| {
    match env::var("NODE_ENV") {
        Ok(val) => {
            match val.as_str() {
                "prod" => true,
                // if anything else is set by user is false
                _ => false,
            }
        }
        // default to prod if nothig is set
        _ => true,
    }
});

/// Save PID
pub fn save_pid(name: &str, pid: u32) {
    // Handle empty case
    match DB_CACHE.get(name.as_bytes()) {
        Ok(Some(_value)) => { /* TODO */ }
        Ok(None) => {
            let process = Process {
                name: name.to_owned(),
                pids: vec![pid].into_iter().collect(),
            };
            let serialized = serde_json::to_vec(&process).unwrap();
            DB_CACHE.put(name.as_bytes(), serialized).unwrap();
        }
        Err(e) => println!("RocksDB operational problem occurred: {}", e),
    }

    // Load, update and save
    let pids_loaded = DB_CACHE.get(name.as_bytes()).unwrap().unwrap();
    let mut process: Process = serde_json::de::from_slice(&pids_loaded).unwrap();
    process.pids.insert(pid);
    let serialized = serde_json::to_vec(&process).unwrap();
    let _res = DB_CACHE.put(name.as_bytes(), serialized);
}

/// Kill all the processes that are running
pub fn kill_zombies(name: &str) {
    if DB_CACHE.get(name.as_bytes()).unwrap().is_none() {
        return;
    }

    let pids_loaded = DB_CACHE.get(name.as_bytes()).unwrap().unwrap();
    let process: Process = serde_json::de::from_slice(&pids_loaded).unwrap();

    println!("Killing zombie '{}' processes...", name);
    println!("Will node disable any systemd services, you must disable those manually");
    use nix::sys::signal::{self, Signal};
    for pid in process.pids.iter() {
        let _res = signal::kill(nix::unistd::Pid::from_raw(*pid as i32), Signal::SIGTERM);
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
    fs::create_dir_all(&logs_dir).expect("could not create logs dir");
    let logs_file = logs_dir.join([file_name, ".log"].join(""));
    println!("Logging in file: {:?}", logs_file);

    File::create(logs_file).expect("could not create log file")
}

/// Start Node, as fullnode
pub fn start_node(config_type: NodeType) -> Result<(), Error> {
    use BINARY_NODE as NODE;
    // if is running do nothing
    if node_health::NodeHealth::new().node_running() {
        println!("{} is already running. Exiting.", NODE);
        return Ok(());
    }

    // Start as validator or fullnode
    let conf = app_config();
    let node_home = conf.workspace.node_home.to_str().unwrap();
    let config_file_name = match config_type {
        NodeType::Validator => format!("{}validator.node.yaml", node_home),
        NodeType::Fullnode => format!("{}fullnode.node.yaml", node_home),
    };

    let child = if *IS_PROD {
        let args = vec!["--config", &config_file_name];
        println!("Starting '{}' with args: {:?}", NODE, args.join(" "));
        spawn_process(
            NODE, args.as_slice(), "node", "failed to run 'libra-node', is it installed?"
        )
    } else {
        let args = vec!["r", "-p", NODE, "--", "--config", &config_file_name];
        println!("Starting 'cargo' with args: {:?}", args.join(" "));
        spawn_process(
            "cargo", args.as_slice(), "node", "failed to run cargo r -p libra-node"
        )
    };

    let pid = &child.id();
    save_pid(NODE, *pid);
    println!("Started new with PID: {}", pid);
    Ok(())
}

/// Stop node, as validator
pub fn stop_node() {
    kill_all(BINARY_NODE);
}

fn kill_all(process: &str) {
    kill_zombies(process);

    let mut child = Command::new("killall")
        .arg(process)
        .spawn()
        .expect(&format!("failed to run killall {}", process));
    child.wait().expect("killall did not exit");
}

/// Spawn process with some options
fn spawn_process(
    binary: &str, args: &[&str], log_file: &str, expect_msg: &str
) -> std::process::Child {
    // Create log file, and pipe stdout/err
    let outputs = create_log_file(log_file);
    let errors = outputs.try_clone().unwrap();

    Command::new(binary)
        .args(args)
        .stdout(Stdio::from(outputs))
        .stderr(Stdio::from(errors))
        .spawn()
        .expect(expect_msg)
}

/// Start Miner
pub fn start_miner() {
    // Stop any processes we may have started and detached from.
    // if is running do nothing
    use BINARY_MINER as MINER;
    if node_health::NodeHealth::new().miner_running() {
        println!("{} is already running. Exiting.", MINER);
        return
    }

    // if node is NOT synced, then should use a backup/upstream node
    // let url = choose_rpc_node().unwrap();
    let use_backup = node_health::NodeHealth::node_is_synced().0;
    
    let child = if *IS_PROD {
        let mut args = vec!["start"];
        if use_backup { args.push("--backup-url"); };
        println!("Starting '{}' with args: {:?}", MINER, args.join(" "));
        spawn_process(
            MINER, args.as_slice(), MINER, "failed to run 'miner', is it installed?"
        )        
    } else {
        let mut args = vec!["r", "-p", MINER, "--", "start"];
        if use_backup { args.push("--backup-url"); };
        println!("Starting 'cargo' with args: {:?}", args.join(" "));
        spawn_process(
            "cargo", args.as_slice(), MINER, "failed to run cargo r -p miner"
        )
    };

    let pid = &child.id();
    save_pid(MINER, *pid);
    println!("Started with PID {} in the background", pid);
}

/// Stop Miner
pub fn stop_miner() {
    kill_all(BINARY_MINER);
}

/// Choose a node to connect for rpc, local or upstream
pub fn choose_rpc_node() -> Option<Url> {
    let conf = app_config().to_owned();

    // check the node is in sync
    // Note this assumes that we can connect to local and to a backup.
    if node_health::NodeHealth::node_is_synced().0 {
        // always choose local node if in sync
        return conf.profile.default_node;
    } else {
        // otherwise use a backup
        // TODO: check all backups in vector to see which connects
        Some(
            conf.profile
                .upstream_nodes
                .unwrap()
                .into_iter()
                .next()
                .unwrap(),
        )
    }
}

///
pub fn run_validator_wizard() -> bool {
    println!("Running validator wizard");
    let mut child = if *IS_PROD {
        Command::new("miner")
            .arg("val-wizard")
            .spawn()
            .expect(&format!("failed to find 'miner', is it installed?"))
    } else {
        let entry_arg = entrypoint::get_args();
        let swarm_arg = if entry_arg.swarm_path.is_some() { 
          format!("--swarm-path {:?}", entry_arg.swarm_path.unwrap())
        } else {"".to_string() };

        let swarm_persona = if entry_arg.swarm_persona.is_some() { 
          format!("--swarm-persona {:?}", entry_arg.swarm_persona.unwrap())
        } else {"".to_string() };

        Command::new("cargo")
            .args(&["r", "-p", "miner", "--"])
            .arg(swarm_arg)
            .arg(swarm_persona)
            .arg("val-wizard")
            .spawn()
            .expect(&format!("failed to run cargo r -p miner"))
    };

    let exit_code = child.wait().expect("failed to wait on miner");
    assert!(exit_code.success());

    true
}
