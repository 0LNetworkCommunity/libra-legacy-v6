//! TxsApp Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.

use abscissa_core::path::{PathBuf};
use ajson;
use crate::commands::CONFIG_FILE;
use dirs;
use libra_global_constants::NODE_HOME;
use libra_types::{waypoint::Waypoint};
use serde::{Deserialize, Serialize};
use std::{fs, io::Write};

/// TxsApp Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct AppConfig {
    /// Workspace config
    pub workspace: Workspace,
    /// User Profile
    pub profile: Profile,
}

impl AppConfig {
    /// Gets the dynamic waypoint from libra node's key_store.json
    pub fn get_waypoint(&self) -> Option<Waypoint> {
        match fs::File::open(self.get_key_store_path()) {
            Ok(file) => {
                let json: serde_json::Value = serde_json::from_reader(file)
                    .expect("could not parse JSON in key_store.json");
                let value = ajson::get(
                    &json.to_string(), "*waypoint.value"
                ).expect("could not find key: waypoint");
                let waypoint: Waypoint = value.to_string().parse().unwrap();
                println!("Info: Got waypoint from key_store.json");
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

    /// Write app config into txs.toml file
    pub fn init_app_configs(path: Option<PathBuf>) -> AppConfig {

        // TODO: Check if configs exist and warn on overwrite.
        let mut txs_config = AppConfig::default();

        txs_config.workspace.node_home = if path.is_some() {
            path.unwrap()
        } else {
            dirs::home_dir().unwrap()
        };

        txs_config.workspace.node_home.push(NODE_HOME);

        fs::create_dir_all(&txs_config.workspace.node_home).unwrap();
        let toml = toml::to_string(&txs_config).unwrap();
        let home_path = txs_config.workspace.node_home.clone();
        let txs_toml_path = home_path.join(CONFIG_FILE);
        let file = fs::File::create(&txs_toml_path);
        file.unwrap().write(&toml.as_bytes())
            .expect("Could not write toml file");

        println!("\ntxs app initialized, file saved to: {:?}", &txs_toml_path);
        txs_config
    }

}

/// Default configuration settings.
///
/// Note: if your needs are as simple as below, you can
/// use `#[derive(Default)]` on AppConfig instead.
impl Default for AppConfig {
    fn default() -> Self {
        Self {
            workspace: Workspace::default(),
            profile: Profile::default(),
        }
    }
}

/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Workspace {
    /// home directory of the libra node, may be the same as Txs.
    pub node_home: PathBuf,
}

impl Default for Workspace {
    fn default() -> Self {
        Self{
            node_home: dirs::home_dir().unwrap().join(NODE_HOME)
        }
    }
}

/// Txs profile to commit this work chain to a particular identity
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Profile {
    /// URL for submitting txs to
    pub url: String,
    /// Waypoint from which the client will sync
    pub waypoint: Waypoint,
    /// Max gas units to pay per transaction
    pub max_gas_unit_for_tx: u64, //1_000_000,
    /// Max coin price per unit of gas
    pub coin_price_per_unit: u64, // in micro_gas
    /// Time in milliseconds to timeout
    pub user_tx_timeout: u64,     // 5_000,

}

impl Default for Profile {
    fn default() -> Self {
        const WAYPOINT: &str = "0:732ea2e1c3c5ee892da11abcd1211f22c06b5cf75fd6d47a9492c21dbfc32a46";
        Self {
            url: "http://localhost:8080".to_owned(),
            waypoint: WAYPOINT.parse::<Waypoint>().unwrap(),
            max_gas_unit_for_tx: 1_000_000,
            coin_price_per_unit: 1, // in micro_gas
            user_tx_timeout: 5_000,
        }
    }
}
