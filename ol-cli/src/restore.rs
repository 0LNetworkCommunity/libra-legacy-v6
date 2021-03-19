//! `restore` functions

use std::io::Write;
use abscissa_core::{status_info, status_ok};
use libra_global_constants::{GENESIS_WAYPOINT, WAYPOINT};
use reqwest;
use anyhow::Error;
use glob::glob;
use serde::{Serialize, Deserialize};
use std::{fs::{self, File}, io::{self}, path::{PathBuf}, process::Command};
use crate::application::app_config;
use libra_secure_storage::{self, OnDiskStorageInternal};
use libra_types::{waypoint::Waypoint};
use libra_secure_storage::KVStorage;

/// Restore database from archive
pub fn fast_forward_db() -> Result<(), Error>{
    let mut backup = Backup::new();

    status_info!("Fetching latest epoch backup", "from epoch archive");
    backup.fetch_backup()?;

    status_info!("Setting waypoint", "key_store.json being updated");
    backup.set_waypoint()?;

    status_info!("Restoring db from archive", "to home path");
    backup.restore_backup()?;
    
    status_info!("Creating fullnode.node.yaml", "to home path");
    backup.create_fullnode_yaml()?;
    Ok(())
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

/// Backup metadata
#[derive(Debug)]
pub struct Backup {
    version_number: u64,
    zip_url: String,
    home_path: PathBuf,
    restore_path: PathBuf,
    zip_path: PathBuf,
    waypoint: Option<Waypoint>
    // node_namespace: String,
}

impl Backup {
    /// Creates a backup info instance
    pub fn new() -> Self {
        let conf = app_config().to_owned();
        let (version_number, zip_url) = get_highest_epoch_zip().unwrap();
        let restore_path = conf.workspace.node_home.join(format!("restore/{}", version_number));
        fs::create_dir_all(&restore_path).unwrap();
        println!("most recent epoch backup: {}", &version_number);

        Backup {
            version_number,
            zip_url,
            home_path: conf.workspace.node_home.clone(),
            restore_path: restore_path.clone(),
            zip_path: conf.workspace.node_home.join(format!("restore/restore-{}.zip", version_number)),
            waypoint: None,
            // TODO: Do we need namespaced waypoints?
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
        let db_path = &self.home_path.join("db/");
        let restore_path = self.restore_path.to_str().unwrap();
        let height = &self.waypoint.unwrap().version();
        restore_epoch(db_path, restore_path);
        restore_transaction(db_path, restore_path);
        restore_snapshot(db_path, restore_path, height);
        Ok(())
    }

    /// parse waypoint from manifest
    pub fn parse_manifest_waypoint(&mut self) -> Result<Waypoint, Error> {
        let manifest_path = self.restore_path.to_str().unwrap();
        for entry in glob(&format!("{}/**/epoch_ending.manifest", manifest_path)).expect("Failed to read glob pattern") {
            match entry {
                Ok(path) => {
                    println!("{:?}", path.display());
                    let data = fs::read_to_string(path).unwrap();
                    let p: Manifest = serde_json::from_str(&data).unwrap();
                    let waypoint = p.waypoints[0];
                    self.waypoint = Some(waypoint);
                    return Ok(waypoint)
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
    pub fn set_waypoint(&mut self) -> Result<Waypoint, Error>{
        let waypoint = self.parse_manifest_waypoint().unwrap();
        let mut storage = libra_secure_storage::Storage::OnDiskStorage(OnDiskStorageInternal::new(self.home_path.join("key_store.json").to_owned()));
        // TODO: Do we need namespaced storage? if not just call storage.set
        storage.set(GENESIS_WAYPOINT, waypoint)?;
        storage.set(WAYPOINT, waypoint)?;

        Ok(waypoint)
        
        // TODO: Do we need namespaced storage for waypoint?
        // let mut nss = NamespacedStorage::new(storage, self.node_namespace.clone().into());
        // nss.set(GENESIS_WAYPOINT, waypoint).unwrap();
        // nss.set(WAYPOINT, waypoint).unwrap();

        // TODO set waypoint in fullnode.node.yaml
    }
    /// Creates a fullnode yaml file with restore waypoint.
    pub fn create_fullnode_yaml(&self) -> Result<(), Error>{

        let yaml = format!(
// NOTE: With yaml formatting Be aware of indents, two spaces
r#"
base:
  data_dir: "{home_path}"
  role: "full_node"
  waypoint: 
    from_config: "{waypoint}"
execution:
  genesis_file_location: ""
full_node_networks:
  - discovery_method: "onchain"
    listen_address: "/ip4/0.0.0.0/tcp/6179"
    network_id: "public"
    seed_addrs:
      252F0B551C80CD9E951D82C6F70792AE:
        - "/ip4/34.82.239.18/tcp/6179/ln-noise-ik/d578327226cc025724e9e5f96a6d33f55c2cfad8713836fa39a8cf7efeaf6a4e/ln-handshake/0"
      ECAF65ADD1B785B0495E3099F4045EC0:
        - "/ip4/167.172.248.37/tcp/6179/ln-noise-ik/f2ce22752b28a14477d377a01cd92411defdb303fa17a08a640128864343ed45/ln-handshake/0"
storage:
  address: "127.0.0.1:6666"
  backup_service_address: "127.0.0.1:6186"
  dir: db
  grpc_max_receive_len: 100000000
  prune_window: 20000
  timeout_ms: 30000
json_rpc:
  address: 127.0.0.1:8080
upstream:
  networks:
    - public
"#,
            home_path = &self.home_path.to_str().expect("no home path provided"),
            waypoint = &self.waypoint.expect("no waypoint provided"),
        );

        let yaml_path = &self.home_path.join("fullnode.node.yaml");
        let mut file = File::create(yaml_path)?;
        file.write_all(&yaml.as_bytes())?;
        status_ok!("Success", format!("file created to {}", yaml_path.to_str().unwrap()));

        Ok(())
    }
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

/// Restores transaction epoch backups
pub fn restore_epoch(db_path: &PathBuf, restore_path: &str, ) {
    let manifest_path = glob(
    &format!("{}/**/epoch_ending.manifest", restore_path)
    ).expect("Failed to read glob pattern").next().unwrap().unwrap();

    let mut child = Command::new("db-restore")
    .arg("--target-db-dir")
    .arg(db_path)
    .arg("epoch-ending")
    .arg("--epoch-ending-manifest")
    .arg(manifest_path.to_str().unwrap())
    .arg("local-fs")
    .arg("--dir")
    .arg(restore_path)
    .spawn()
    .expect("failed to execute child");

    let ecode = child.wait()
            .expect("failed to wait on child");

    assert!(ecode.success());
    status_ok!("Success", "epoch restored");
}

/// Restores transaction type backups
pub fn restore_transaction(db_path: &PathBuf, restore_path: &str, ) {
    let manifest_path = glob(
    &format!("{}/**/transaction.manifest", restore_path)
    ).expect("Failed to read glob pattern").next().unwrap().unwrap();

    let mut child = Command::new("db-restore")
    .arg("--target-db-dir")
    .arg(db_path)
    .arg("transaction")
    .arg("--transaction-manifest")
    .arg(manifest_path.to_str().unwrap())
    .arg("local-fs")
    .arg("--dir")
    .arg(restore_path)
    .spawn()
    .expect("failed to execute child");

    let ecode = child.wait()
            .expect("failed to wait on child");

    assert!(ecode.success());
    status_ok!("Success", "transactions restored");
}

/// Restores snapshot type backups
pub fn restore_snapshot(db_path: &PathBuf, restore_path: &str, epoch_height: &u64) {
    let manifest_path = glob(
    &format!("{}/**/state.manifest", restore_path)
    ).expect("Failed to read glob pattern").next().unwrap().unwrap();

    let mut child = Command::new("db-restore")
    .arg("--target-db-dir")
    .arg(db_path)
    .arg("state-snapshot")
    .arg("--state-manifest")
    .arg(manifest_path)
    .arg("--state-into-version")
    .arg(&epoch_height.to_string())
    .arg("local-fs")
    .arg("--dir")
    .arg(restore_path)
    .spawn()
    .expect("failed to execute child");

    let ecode = child.wait()
            .expect("failed to wait on child");

    assert!(ecode.success());
    status_ok!("Success", "state snapshot restored");
}