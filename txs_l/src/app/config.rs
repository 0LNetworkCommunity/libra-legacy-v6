//! MinerApp Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.

use std::{net::Ipv4Addr, fs};
use byteorder::{LittleEndian, WriteBytesExt};
use libra_types::{account_address::AccountAddress, transaction::authenticator::AuthenticationKey, waypoint::Waypoint};
use rustyline::Editor;
use serde::{Deserialize, Serialize};
use abscissa_core::path::{PathBuf};
use crate::delay::delay_difficulty;
use crate::submit_tx::TxParams;
use ajson;
use dirs;
use libra_global_constants::NODE_HOME;
use crate::commands::CONFIG_FILE;
use std::{io::Write};


/// MinerApp Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct TxsConfig {  // todo
    /// Workspace config
    pub workspace: Workspace,
    /// ..
    pub url: String,
    /// 
    pub waypoint: Option<String>,
    ///
    pub max-trans-gas... : ..,
}

impl TxsConfig {
    /// Gets the dynamic waypoint from libra node's key_store.json
    pub fn get_waypoint(&self) -> Option<Waypoint> {
        match fs::File::open(self.get_key_store_path()) {
            Ok(file) => {
                let json: serde_json::Value = serde_json::from_reader(file)
                    .expect("could not parse JSON in key_store.json");
                let value = ajson::get(&json.to_string(), "*waypoint.value").expect("could not find key: waypoint");
                dbg!(&value);
                let waypoint: Waypoint = value.to_string().parse().unwrap();
                Some(waypoint)
            }
            Err(err) => {
            println!("key_store.json not found. {:?}", err);
            None
            }
        }
    }

    /// Get where node key_store.json stored.
    pub fn get_key_store_path(&self)-> PathBuf {
        let mut home = self.workspace.node_home.clone();
        home.push("key_store.json");
        home
    }

        /// Get where node key_store.json stored.
    pub fn init_miner_configs(
        authkey: AuthenticationKey, account: AccountAddress, path: Option<PathBuf>) -> MinerConfig {

        // TODO: Check if configs exist and warn on overwrite.
        let mut miner_configs = MinerConfig::default();

        miner_configs.workspace.node_home = if path.is_some() {
            path.unwrap()
        } else {
            dirs::home_dir().unwrap()
        };

        miner_configs.workspace.node_home.push(NODE_HOME);
        
        fs::create_dir_all(&miner_configs.workspace.node_home).unwrap();

        let toml = toml::to_string(&miner_configs).unwrap();
        let home_path = miner_configs.workspace.node_home.clone();
        let miner_toml_path = home_path.join(CONFIG_FILE);
        let file = fs::File::create(&miner_toml_path);
        file.unwrap().write(&toml.as_bytes())
            .expect("Could not write toml file");

        println!("\ntxs app initialized, file saved to: {:?}", &miner_toml_path);
        miner_configs
    }

}

/// Default configuration settings.
///
/// Note: if your needs are as simple as below, you can
/// use `#[derive(Default)]` on MinerConfig instead.
impl Default for TxsConfig {
    fn default() -> Self {
        Self {
            workspace: Workspace::default(),
            // todo ...
        }
    }
}

/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Workspace {
    /// home directory of the libra node, may be the same as miner.
    pub node_home: PathBuf,
}

impl Default for Workspace {
    fn default() -> Self {
        Self{
            node_home: dirs::home_dir().unwrap().join(NODE_HOME)
        }
    }
}

