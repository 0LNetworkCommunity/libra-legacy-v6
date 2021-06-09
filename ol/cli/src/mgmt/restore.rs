//! `restore` functions

use std::{env, io::Write, process::Stdio};
use abscissa_core::{status_ok};
use diem_global_constants::{GENESIS_WAYPOINT, WAYPOINT};
use once_cell::sync::Lazy;
use reqwest;
use anyhow::Error;
use glob::glob;
use serde::{Serialize, Deserialize};
use std::{fs::{self, File}, io::{self}, path::{PathBuf}, process::Command};
use crate::application::app_config;
use diem_secure_storage::{self, NamespacedStorage, OnDiskStorage};
use diem_types::{waypoint::Waypoint};
use diem_secure_storage::KVStorage;

const GITHUB_ORG: &str = "OLSF";
/// Check if we are in testnet mode
pub static GITHUB_REPO: Lazy<&str> = Lazy::new(||{
    if *IS_DEVNET {
        "dev-epoch-archive"
    } else {
        "epoch-archive"
    }
});

/// Are we restoring devnet database
pub static IS_DEVNET: Lazy<bool> = Lazy::new(||{  
    match env::var("TEST") {
        Ok(val) => {
            match val.as_str() {
                "y" =>  true,
                // if anything else is set by user is false
                _ => false 
            }
        }
        // default to prod if nothig is set
        _ => false
    }
});

/// Restore database from archive
pub fn fast_forward_db(verbose: bool, epoch: Option<u64>) -> Result<(), Error>{
    let mut backup = Backup::new(epoch);

    println!("fetching latest epoch backup from epoch archive");
    backup.fetch_backup(verbose)?;

    println!("\nSetting waypoint key_store.json being updated");
    backup.set_waypoint()?;

    println!("\nRestoring db from archive to home path");
    backup.restore_backup(verbose)?;
    
    println!("\nCreating fullnode.node.yaml to home path");
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
    waypoint: Option<Waypoint>,
    node_namespace: String,
}

impl Backup {
    /// Creates a backup info instance
    pub fn new(epoch: Option<u64>) -> Self {
        let conf = app_config().to_owned();
        let (restore_epoch, zip_url) = if let Some(e) = epoch {
          (e, get_zip_url(e).unwrap())
        } else {
          get_highest_epoch_zip().expect(&format!("could not find a zip backup at url: {}", GITHUB_REPO.clone()))
        };

        let restore_path = conf.workspace.node_home.join(format!("restore/{}", restore_epoch));
        fs::create_dir_all(&restore_path).unwrap();
        
        println!("DB fast forward to epoch: {}", &restore_epoch);

        Backup {
            version_number: restore_epoch,
            zip_url,
            home_path: conf.workspace.node_home.clone(),
            restore_path: restore_path.clone(),
            zip_path: conf.workspace.node_home.join(format!("restore/restore-{}.zip", restore_epoch)),
            waypoint: None,
            node_namespace: format!("{}-oper", conf.profile.auth_key.clone()),
        }
    }
    /// Fetch backups
    pub fn fetch_backup(&self, verbose: bool) -> Result<(), Error> {    
        let mut resp = reqwest::blocking::get(&self.zip_url).expect("request failed");
        let mut out = File::create(&self.zip_path).expect("failed to create file");
        io::copy(&mut resp, &mut out).expect("failed to copy content");
        
        let stdio_cfg = if verbose { Stdio::inherit() } else { Stdio::null() };

        
        let mut child = Command::new("unzip")
        .arg("-o")
        .arg(&self.zip_path)
        .arg("-d")
        .arg(&self.home_path.join("restore/"))
        .stdout(stdio_cfg)
        .spawn()
        .expect("failed to execute child");

        let ecode = child.wait().expect("failed to wait on child");

        assert!(ecode.success());

        println!("fetched archive zip, copied to {:?}", &self.home_path.join("restore/"));
        status_ok!("\nArchive downloaded", "\n...........................\n");


        Ok(())
    }

    /// Restore Backups
    pub fn restore_backup(&self, verbose: bool) -> Result<(), Error>{
        let db_path = &self.home_path.join("db/");
        let restore_path = self.restore_path.to_str().unwrap();
        let height = &self.waypoint.unwrap().version();
        restore_epoch(db_path, restore_path, verbose);
        restore_transaction(db_path, restore_path, verbose);
        restore_snapshot(db_path, restore_path, height, verbose);
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
        let storage = diem_secure_storage::Storage::OnDiskStorage(
            OnDiskStorage::new(self.home_path.join("key_store.json").to_owned())
        );
        let mut ns_storage = diem_secure_storage::Storage::NamespacedStorage(
            NamespacedStorage::new(
                storage,
                self.node_namespace.clone()
            )
        );
        ns_storage.set(GENESIS_WAYPOINT, waypoint)?;
        ns_storage.set(WAYPOINT, waypoint)?;

        println!("waypoint retrieve, updated key_store.json");
        status_ok!("\nWaypoint set", "\n...........................\n");

        Ok(waypoint)
    }
    /// Creates a fullnode yaml file with restore waypoint.
    pub fn create_fullnode_yaml(&self) -> Result<(), Error>{

        let yaml = if *IS_DEVNET {
            devnet_yaml(
            &self.home_path.to_str().expect("no home path provided"), 
            &self.waypoint.expect("no waypoint provided").to_string()
            )
        } else {
            prod_yaml(
            &self.home_path.to_str().expect("no home path provided"), 
            &self.waypoint.expect("no waypoint provided").to_string()
            )
        };

        let yaml_path = &self.home_path.join("fullnode.node.yaml");
        let mut file = File::create(yaml_path)?;
        file.write_all(&yaml.as_bytes())?;

        println!("fullnode yaml created, file saved to: {:?}", yaml_path.to_str().unwrap());
        status_ok!("\nFullnode config written", "\n...........................\n");

        Ok(())
    }
}


fn get_highest_epoch_zip() -> Result<(u64, String), Error> {
    let client = reqwest::blocking::Client::builder()
    .user_agent(APP_USER_AGENT)
    .build()?;

    let request_url = format!("https://api.github.com/repos/{owner}/{repo}/contents/",
                              owner = GITHUB_ORG.clone(),
                              repo = GITHUB_REPO.clone());
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
        owner = GITHUB_ORG.clone(),
        repo = GITHUB_REPO.clone(),
        highest_epoch = highest_epoch.to_string(),
        ))
    )
}

fn get_zip_url(epoch: u64) -> Result<String, Error> {
    Ok( 
      format!(
        "https://raw.githubusercontent.com/{owner}/{repo}/main/{epoch}.zip",
        owner = GITHUB_ORG.clone(),
        repo = GITHUB_REPO.clone(),
        epoch = epoch.to_string(),
      )
    )
}

/// Restores transaction epoch backups
pub fn restore_epoch(db_path: &PathBuf, restore_path: &str, verbose: bool) {
    let manifest_path = glob(
        &format!("{}/**/epoch_ending.manifest", restore_path)
    ).expect("Failed to read glob pattern").next().unwrap().unwrap();
    
    let stdio_cfg = if verbose { Stdio::inherit() } else { Stdio::null() };

    let mut child = Command::new("db-restore")
    .arg("--target-db-dir")
    .arg(db_path)
    .arg("epoch-ending")
    .arg("--epoch-ending-manifest")
    .arg(manifest_path.to_str().unwrap())
    .arg("local-fs")
    .arg("--dir")
    .arg(restore_path)
    .stdout(stdio_cfg)
    .spawn()
    .expect("failed to execute child");

    let ecode = child.wait().expect("failed to wait on child");

    assert!(ecode.success());
    
    println!("epoch metadata restored from epoch archive, files saved to: {:?}", restore_path);
    status_ok!("\nEpoch metadata restored", "\n...........................\n");
}

/// Restores transaction type backups
pub fn restore_transaction(db_path: &PathBuf, restore_path: &str, verbose: bool) {
    let manifest_path = glob(
    &format!("{}/**/transaction.manifest", restore_path)
    ).expect("Failed to read glob pattern").next().unwrap().unwrap();

    let stdio_cfg = if verbose { Stdio::inherit() } else { Stdio::null() };

    let mut child = Command::new("db-restore")
    .arg("--target-db-dir")
    .arg(db_path)
    .arg("transaction")
    .arg("--transaction-manifest")
    .arg(manifest_path.to_str().unwrap())
    .arg("local-fs")
    .arg("--dir")
    .arg(restore_path)
    .stdout(stdio_cfg)
    .spawn()
    .expect("failed to execute child");

    let ecode = child.wait().expect("failed to wait on child");

    assert!(ecode.success());
    
    println!("transactions restored from epoch archive,");
    status_ok!("\nTransactions restored", "\n...........................\n");
}

/// Restores snapshot type backups
pub fn restore_snapshot(db_path: &PathBuf, restore_path: &str, epoch_height: &u64, verbose: bool) {
    let manifest_path = glob(
    &format!("{}/**/state.manifest", restore_path)
    ).expect("Failed to read glob pattern").next().unwrap().unwrap();

    let stdio_cfg = if verbose { Stdio::inherit() } else { Stdio::null() };

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
    .stdout(stdio_cfg)
    .spawn()
    .expect("failed to execute child");

    let ecode = child.wait()
            .expect("failed to wait on child");

    assert!(ecode.success());
    println!("state snapshot restored from epoch archive,");
    status_ok!("\nState snapshot restored", "\n...........................\n");
}



fn prod_yaml(home_path: &str, waypoint: &str) -> String {
    format!(
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
      0790D40397E7CAE291D235D73406593C:
        - /ip4/23.251.145.225/tcp/6179/ln-noise-ik/3dc2f343e3aae691f1a26c613c1cad3f04105741cf594d77fc7c439b63049805/ln-handshake/0
      BD69BD2D1946419A878723869789BB0D:
        - /ip4/202.182.125.18/tcp/6179/ln-noise-ik/6c8ab0b3a433f9ba2f4a11a4f831cc100d6641ac39b0181947027ca28eb4051a/ln-handshake/0
      D275B9DA59F17F8C0D3231322E6E5014:
        - /ip4/35.230.7.230/tcp/6179/ln-noise-ik/d578327226cc025724e9e5f96a6d33f55c2cfad8713836fa39a8cf7efeaf6a4e/ln-handshake/0
      29A38825D33A6E3A0CB7DC58BD240921:
        - /ip4/167.172.248.37/tcp/6179/ln-noise-ik/f2ce22752b28a14477d377a01cd92411defdb303fa17a08a640128864343ed45/ln-handshake/0
      49B3B35653680B0C1EEEE7C04FC1846A:
        - /ip4/98.158.184.17/tcp/6179/ln-noise-ik/3dbcb29d8083e28681285e92e2a1ecd37ebd6c559f2056cd9634899a0c789168/ln-handshake/0
      E14CBB40F7A5E4EDA20D6D416AAC2F26:
        - /ip4/157.245.122.242/tcp/6179/ln-noise-ik/8e85a295d9217427eaf30dd552b972e28cc1bf1db9c6e7a6fb12e046677d0424/ln-handshake/0
      4108BCE184D13CBA495D42B85C24A643:
        - /ip4/35.230.40.123/tcp/6179/ln-noise-ik/0f2e8a15abedd16f64d4651e79b572084943bf01a6a49f30928dd9d604790226/ln-handshake/0
      CA81CAADC4251AE817DDE81ED9977035:
        - /ip4/188.166.23.18/tcp/6179/ln-noise-ik/158e00c70b175ad96af7e4bb946a184d54460af39eda9973e6fe8080a1dfed4d/ln-handshake/0
      9FD07DCEE0550061968E4C2213DE730F:
        - /ip4/35.233.185.59/tcp/6179/ln-noise-ik/eac699875537ba2020e1041ec185f3e3dd165623fa31a53bb9ad666a7caefd5f/ln-handshake/0
      4C98C0AFAE08CD1FE26581C3F091083B:
        - /ip4/68.183.61.250/tcp/6179/ln-noise-ik/7cc64629542062aa960a04255e235aaf5fd85991bf49712bcd5a702e07fd8f13/ln-handshake/0
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
        home_path = home_path,
        waypoint = waypoint,
    )
}


fn devnet_yaml(home_path: &str, waypoint: &str) -> String {
    format!(
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
      1014744036973B187864B1A631F5977B:
        - /ip4/104.131.56.224/tcp/6179/ln-noise-ik/3a12e9f2fb9fe6ba08ec565e1a10d331e8982b1e4e2f7b53c0c94fb6cab56428/ln-handshake/0
      E8A275BF7051AA18542BBD57BD813E2B:
        - /ip4/167.71.84.248/tcp/6179/ln-noise-ik/1469513dfddeeb0a11f3cc54f8cae323cbd5b129ec2cf3ed63e11103984e7d3d/ln-handshake/0
      0D49B2FF734982C7D47480481707BC4C:
        - /ip4/157.230.15.42/tcp/6179/ln-noise-ik/493847429420549694a18a82bc9b1b1ce21948bbf1cd4c5cee9ece0fb8ead50a/ln-handshake/0
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
        home_path = home_path,
        waypoint = waypoint,
    )
}