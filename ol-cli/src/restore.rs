//! `restore` functions

use abscissa_core::status_info;
use libra_global_constants::{GENESIS_WAYPOINT, WAYPOINT};
// use serde::Deserialize;
use reqwest;

use anyhow::Error;
use glob::glob;
use serde::{Serialize, Deserialize};
use warp::Buf;
use std::{fs::{self, File}, io::{self, Write}, path::{Path, PathBuf}, process::Command};
use crate::check;
use crate::application::app_config;
use libra_secure_storage::{self, NamespacedStorage, OnDiskStorageInternal};
use libra_types::{waypoint::Waypoint};
// use libra_crypto::ed25519::Ed25519PublicKey;
use libra_global_constants::{OPERATOR_ACCOUNT, OWNER_ACCOUNT};
// use libra_management::{config:: ConfigPath, error::Error, secure_backend::{SecureBackend, SharedBackend}};
// use libra_secure_storage::OnDiskStorageInternal;
use libra_types::transaction::authenticator::AuthenticationKey;
// use std::path::PathBuf;
// use structopt::StructOpt;
use libra_secure_storage::CryptoStorage;
use libra_secure_storage::KVStorage;

#[derive(Deserialize, Debug)]
struct User {
    login: String,
    id: u32,
}

#[derive(Serialize, Deserialize)]
struct Manifest {
    waypoints: Vec<Waypoint>,
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
    // node_namespace: String,
}

impl Backup {
    /// Creates a backup info instance
    pub fn new() -> Self {
        let conf = app_config().to_owned();
        let (version_number, zip_url) = get_highest_epoch_zip().unwrap();
        let restore_path = conf.home_path.join(format!("restore/{}", version_number));
        fs::create_dir_all(&restore_path).unwrap();
        println!("most recent epoch backup: {}", &version_number);

        Backup {
            version_number,
            zip_url,
            home_path: conf.home_path.clone(),
            restore_path: restore_path.clone(),
            zip_path: conf.home_path.join(format!("restore/restore-{}.zip", version_number)),
            // node_namespace: conf.node_namespace,
        }
    }
    /// Fetch backups
    pub fn fetch_backup(&self) -> Result<(), Error> {    
        let mut resp = reqwest::blocking::get(&self.zip_url).expect("request failed");
        let mut out = File::create(&self.zip_path).expect("failed to create file");
        io::copy(&mut resp, &mut out).expect("failed to copy content");
        let mut child = Command::new("unzip")
            .arg("-o")
            .arg(&self.zip_path)
            .arg("-d")
            .arg(&self.home_path.join("restore/"))
            .spawn()
            .expect("failed to execute child");

        let ecode = child.wait()
                    .expect("failed to wait on child");

        assert!(ecode.success());
        Ok(())
    }

    /// Restore Backups
    pub fn restore_backup(&self) -> Result<(), Error>{
        let restore_method = "epoch-ending";
        let db_path = &self.home_path.join("db/");
        dbg!(db_path);
        let manifest_path = glob(
            &format!("{}/**/epoch_ending.manifest", &self.restore_path.to_str().unwrap())
        ).expect("Failed to read glob pattern").next().unwrap().unwrap();
        dbg!(&manifest_path);
        dbg!(&self.restore_path);

        let mut child = Command::new("db-restore")
            .arg("--target-db-dir")
            .arg(db_path)
            .arg(restore_method)
            .arg("--epoch-ending-manifest")
            .arg(manifest_path.to_str().unwrap())
            .arg("local-fs")
            .arg("--dir")
            .arg(&self.restore_path)
            .spawn()
            .expect("failed to execute child");

        let ecode = child.wait()
                    .expect("failed to wait on child");

        assert!(ecode.success());
//         restore-epoch:
// 	db-restore --target-db-dir ${DB_PATH} epoch-ending --epoch-ending-manifest ${ARCHIVE_PATH}/${EPOCH}/epoch_ending_${EPOCH}*/epoch_ending.manifest local-fs --dir ${ARCHIVE_PATH}/${EPOCH}

// restore-transaction:
// 	db-restore --target-db-dir ${DB_PATH} transaction --transaction-manifest ${ARCHIVE_PATH}/${EPOCH}/transaction_${EPOCH_HEIGHT}*/transaction.manifest local-fs --dir ${ARCHIVE_PATH}/${EPOCH}

// restore-snapshot:
// 	db-restore --target-db-dir ${DB_PATH} state-snapshot --state-manifest ${ARCHIVE_PATH}/${EPOCH}/state_ver_${EPOCH_HEIGHT}*/state.manifest --state-into-version ${EPOCH_HEIGHT} local-fs --dir ${ARCHIVE_PATH}/${EPOCH}

        Ok(())
    }

    pub fn test_waypoint() {
        let backup = Self::new();
        let wp = backup.parse_manifest_waypoint().unwrap();
        // backup.set_waypoint(&wp);
    }

    pub fn parse_manifest_waypoint(&self) -> Result<Waypoint, Error> {
        // Some JSON input data as a &str. Maybe this comes from the user.

        let manifest_path = self.restore_path.to_str().unwrap();
        for entry in glob(&format!("{}/**/epoch_ending.manifest", manifest_path)).expect("Failed to read glob pattern") {
            match entry {
                Ok(path) => {
                    println!("{:?}", path.display());
                    let data = fs::read_to_string(path).unwrap();
                    let p: Manifest = serde_json::from_str(&data).unwrap();
                    return Ok(p.waypoints[0])
                },
                Err(e) => {
                    println!("{:?}", e);
                    return Err(Error::from(e))
                },
            }
            
        }

        Err(Error::msg("no manifest found"))

    }

    /// Write Waypoint
    pub fn set_waypoint(&self) {
        let waypoint = self.parse_manifest_waypoint().unwrap();
        let mut storage = libra_secure_storage::Storage::OnDiskStorage(OnDiskStorageInternal::new(self.home_path.join("key_store.json").to_owned()));
        // TODO: Do we need namespaced storage? if not just call storage.set
        storage.set(GENESIS_WAYPOINT, waypoint).unwrap();
        storage.set(WAYPOINT, waypoint).unwrap();
        
        // TODO: Do we need namespaced storage for waypoint?
        // let mut nss = NamespacedStorage::new(storage, self.node_namespace.clone().into());
        // nss.set(GENESIS_WAYPOINT, waypoint).unwrap();
        // nss.set(WAYPOINT, waypoint).unwrap();

        // TODO set waypoint in fullnode.node.yaml
    }
}

/// Restore database from archive
pub fn fast_forward_db() -> Result<(), Error>{
    let backup = Backup::new();

    status_info!("fetching latest epoch archive", "");
    backup.fetch_backup()?;

    status_info!("restoring db from archive", "");
    backup.restore_backup()?;

    status_info!("setting waypoint", "");
    backup.set_waypoint();
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


// pub fn insert_waypoint() -> Result<(), Error> {
//     set_waypoint(
//         &PathBuf::from("/root/.0L/"),
//     "87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5-oper",
//     &"48328718:0f8ae2d0e6db807f18098da10ad896fe3e712539de836dcb73e599d81d6e72ca".parse::<Waypoint>().unwrap(),
//     );
//     Ok(())
// }

