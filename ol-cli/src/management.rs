//! `trigger` functions

use serde::Deserialize;
use reqwest::{
    Error,
};
use sled::{self, IVec};


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

/// Start Node, as fullnode
pub fn start_fullnode() {
    use std::process::Command;

    let mut child = Command::new("ls")
                        .arg("/root/.0L/")
                        .spawn()
                        .expect("failed to execute child");

    let pid = &child.id();

    let tree = sled::open("/tmp/ol-sled-db-pid").expect("open");
    // let vec_pid = vec![pid];
    let ivec = IVec::from("value");
    tree.insert(b"pids", ivec).unwrap();


    println!("pid: {}", pid);


    println!("{:#?}", &child);

    let ecode = child.wait()
                    .expect("failed to wait on child");

    assert!(ecode.success());

}

/// Start node, as validator
pub fn start_validator() {}

/// Stop node, as validator
pub fn stop_node() {}

/// Start Miner
pub fn start_miner() {}

/// Stop Miner
pub fn stop_miner() {}


