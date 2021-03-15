//! `trigger` functions

// use serde::Deserialize;
use reqwest::{
    Error,
};
use serde::{Serialize, Deserialize};
use std::process::Command;
use crate::check;
#[derive(Deserialize, Debug)]
struct User {
    login: String,
    id: u32,
}



#[derive(Deserialize, Debug)]
struct GithubFile {
    name: String,
    path: String,
    #[serde(alias = "type")]
    file_type: String,
}


// Name your user agent after the app
static APP_USER_AGENT: &str = concat!(
env!("CARGO_PKG_NAME"),
"/",
env!("CARGO_PKG_VERSION"),
);

/// Restore database from archive
pub fn fast_forward_db() {
    fetch_backups().unwrap();
    restore_backup();
}
/// Fetch backups
pub fn fetch_backups() -> Result<(), Error> {
    // get the highest epoch zip file
    get_highest_epoch_zip()?;

    // unzip in hope path
    Ok(())
}

fn get_highest_epoch_zip() -> Result<(), Error> {
    let client = reqwest::blocking::Client::builder()
    .user_agent(APP_USER_AGENT)
    .build()?;

    let request_url = format!("https://api.github.com/repos/{owner}/{repo}/contents/",
                              owner = "OLSF",
                              repo = "epoch-archive");
    println!("{}", request_url);
    let response = client.get(&request_url).send()?;
    // let text = response.text()?;
    // println!("{:?}", &text);

    let files: Vec<GithubFile> = response.json()?;
    println!("{:?}", files);

    let filter = files.iter()
    .filter(|file| {
        // true
        file.file_type == "file".to_owned()
    });
    println!("{:?}", filter);

    Ok(())
}

/// Restore Backups
pub fn restore_backup() {}

/// Write Waypoint
pub fn write_waypoint() {}

// fn get_sled() -> Db {
//     sled::open("/tmp/ol-sled-db-pid").expect("open")
// }


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


