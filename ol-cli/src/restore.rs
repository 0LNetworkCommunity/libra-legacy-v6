//! `restore` functions

// use serde::Deserialize;
use reqwest::{
    Error,
};
use serde::{Serialize, Deserialize};
use warp::Buf;
use std::{fs::{self, File}, io::{self, Write}, path::{Path, PathBuf}, process::Command};
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

#[derive(Debug)]
pub struct Backup {
    version_number: u64,
    zip_url: String,
    home_path: PathBuf,
    restore_path: PathBuf,
    zip_path: PathBuf,
}

impl Backup {
    /// Creates a backup info instance
    pub fn new() -> Self {
        let conf = app_config().to_owned();
        let (version_number, zip_url) = get_highest_epoch_zip().unwrap();
        let restore_path = conf.home_path.join(format!("restore-{}/", version_number));
        fs::create_dir_all(&restore_path).unwrap();

        Backup {
            version_number,
            zip_url,
            home_path: conf.home_path.clone(),
            restore_path: restore_path.clone(),
            zip_path: conf.home_path.join(format!("restore-{}.zip", version_number))
        }
    }
    /// Fetch backups
    pub fn fetch_backup(&self) -> Result<(), Error> {
        dbg!(&self);
        let mut resp = reqwest::blocking::get(&self.zip_url).expect("request failed");
        let mut out = File::create(&self.zip_path).expect("failed to create file");
        io::copy(&mut resp, &mut out).expect("failed to copy content");

        let mut child = Command::new("unzip")
            .arg("-j") // prevents an extra directory layer
            .arg(&self.zip_path)
            // .arg("-d")
            // .arg(&self.restore_path)
            .spawn()
            .expect("failed to execute child");

        let ecode = child.wait()
                    .expect("failed to wait on child");

        assert!(ecode.success());
        Ok(())
    }

    /// Restore Backups
    pub fn restore_backup(&self) -> Result<(), Error>{
//         restore-epoch:
// 	db-restore --target-db-dir ${DB_PATH} epoch-ending --epoch-ending-manifest ${ARCHIVE_PATH}/${EPOCH}/epoch_ending_${EPOCH}*/epoch_ending.manifest local-fs --dir ${ARCHIVE_PATH}/${EPOCH}

// restore-transaction:
// 	db-restore --target-db-dir ${DB_PATH} transaction --transaction-manifest ${ARCHIVE_PATH}/${EPOCH}/transaction_${EPOCH_HEIGHT}*/transaction.manifest local-fs --dir ${ARCHIVE_PATH}/${EPOCH}

// restore-snapshot:
// 	db-restore --target-db-dir ${DB_PATH} state-snapshot --state-manifest ${ARCHIVE_PATH}/${EPOCH}/state_ver_${EPOCH_HEIGHT}*/state.manifest --state-into-version ${EPOCH_HEIGHT} local-fs --dir ${ARCHIVE_PATH}/${EPOCH}

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
    let response = client.get(&request_url).send()?;

    let files: Vec<GithubFile> = response.json()?;
    let mut filter: Vec<u64> = files.into_iter()
    .filter(|file|{
        file.file_type == "dir"
    })
    .map(|file| {
        // true
        file.name.parse::<u64>().unwrap_or(0)
    })
    .collect();
    filter.sort();
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

