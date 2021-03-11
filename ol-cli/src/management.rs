//! `trigger` functions

// use serde::Deserialize;
use reqwest::{
    Error,
};
use sled::{self, Db};
use serde::{Serialize, Deserialize};
use std::process::Command;

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


// let mut headers = Headers::new();
// headers.set(UserAgent("hyper/0.5.2".to_owned()));

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

fn get_sled() -> Db {
    sled::open("/tmp/ol-sled-db-pid").expect("open")
}


#[derive(Serialize, Deserialize, Debug)]
struct Process {
    name: String,
    pid: Vec<u32>,
}
/// Sled test
pub fn save_pid(name: &str, pid: &u32) {

    let tree = sled::open("/tmp/ol-sled-db-pid").expect("open");
    let point = Process { name: name.to_owned(), pid: vec![*pid] };
    // Convert the Process to bytes.
    let serialized = serde_json::to_vec(&point).unwrap();
    // println!("{:#?}", serialized);
    tree.insert(b"pids", serialized).unwrap();
    let pid_saved = tree.get(b"pids").unwrap().unwrap();
    // println!("pid_saved: {:#?}", pid_saved);
}

/// Kill all the processes that are running
pub fn kill_zombies(name: &str) {
    let db = get_sled();
    let pid_saved = db.get(b"pids").unwrap().unwrap();

    // TODO: Get all the processes from sled and sigkill all them.
    // let process = pid_saved.to_vec();
    // pid_saved.iter()
    // .filter(|process| { 
        
    // })
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
        NodeType::Validator => {format!("{}fullnode.node.yaml", node_home)}
        NodeType::Fullnode => {format!("{}validator.node.yaml", node_home)}
    };

    // Stop any processes we may have started and detached from.
    kill_zombies(BINARY);

    let mut child = Command::new(BINARY)
                        // .arg(BINARY)
                        .arg("--config")
                        .arg(config_file_name)
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();
    println!("pid: {}", pid);
    save_pid(BINARY, pid);

    //TODO: Instead of waiting, detach from, here.
    let ecode = child.wait()
                    .expect("failed to wait on child");

    assert!(ecode.success());

}


/// Stop node, as validator
pub fn stop_node() {
    kill_zombies("libra-node");
}

/// Start Miner
pub fn start_miner() {}

/// Stop Miner
pub fn stop_miner() {}


