//! `restore` functions

// use serde::Deserialize;
use reqwest::{
    Error,
};
use serde::{Serialize, Deserialize};
use warp::Buf;
use std::{fs::File, io::{self, Write}, path::{Path, PathBuf}, process::Command};
use crate::check;
use crate::application::app_config;

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

pub struct Backup {
    version_number: u64,
    zip_url: String,
    home_path: PathBuf,
    restore_path: PathBuf,
    zip_path: PathBuf,
}

impl Backup {
    /// Creates a backup info instance
    pub fn new() -> Self{
        let conf = app_config().to_owned();
        let (version_number, zip_url) = get_highest_epoch_zip().unwrap();
        Backup {
            version_number,
            zip_url,
            home_path: conf.home_path.clone(),
            restore_path: conf.home_path.join("restore/"),
            zip_path: conf.home_path.join(format!("restore/{}.zip", version_number))
        }
    }
    /// Fetch backups
    pub fn fetch_backup(&self) -> Result<(), Error> {
        let mut resp = reqwest::blocking::get(&self.zip_url).expect("request failed");
        let mut out = File::create(&self.zip_path).expect("failed to create file");
        io::copy(&mut resp, &mut out).expect("failed to copy content");

            let mut child = Command::new("unzip")
                .arg("-j") // prevents an extra directory layer
                .arg(&self.zip_path)
                .arg("-d")
                .arg(&self.restore_path)
                .spawn()
                .expect("failed to execute child");

        let ecode = child.wait()
                    .expect("failed to wait on child");

        assert!(ecode.success());
        Ok(())
    }

    /// Restore Backups
    pub fn restore_backup(&self) -> Result<(), Error>{
        Ok(())
    }

    /// Write Waypoint
    pub fn write_waypoint() {
        
    }

}
/// Restore database from archive
pub fn fast_forward_db() -> Result<(), Error>{
    let backup = Backup::new();
    backup.fetch_backup()?;
    backup.restore_backup()?;
    Ok(())
}


fn get_highest_epoch_zip() -> Result<(u64, String), Error> {
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

    let mut filter: Vec<u64> = files.into_iter()
    .filter(|file|{
        file.file_type == "dir"
    })
    .map(|file| {
        // true
        dbg!(&file);
        file.name.parse::<u64>().unwrap_or(0)
    })
    .collect();
    println!("{:?}", &filter);
    filter.sort();
    println!("{:?}", &filter);
    let highest_epoch = filter.pop().unwrap();
    // TODO: Change to new directory structure
    Ok(
        (highest_epoch, 
            format!("https://raw.githubusercontent.com/{owner}/{repo}/main/{highest_epoch}.zip",
        owner = "OLSF",
        repo = "epoch-archive",
        highest_epoch = highest_epoch.to_string(),
        ))
    )
}

