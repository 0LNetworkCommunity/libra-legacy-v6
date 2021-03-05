//! MinerApp Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.

use std::{fs};
use libra_types::{account_address::AccountAddress, transaction::authenticator::AuthenticationKey, waypoint::Waypoint};
use serde::{Deserialize, Serialize};
use abscissa_core::path::{PathBuf};
use ajson;
use dirs;
use libra_global_constants::NODE_HOME;
use crate::commands::CONFIG_FILE;
use std::{io::Write};

/// MinerApp Configuration
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
    pub fn init_app_configs(
        authkey: AuthenticationKey,
        account: AccountAddress,
        path: Option<PathBuf>
    ) -> AppConfig {

        // TODO: Check if configs exist and warn on overwrite.
        let mut miner_configs = AppConfig::default();

        miner_configs.workspace.node_home = if path.is_some() {
            path.unwrap()
        } else {
            dirs::home_dir().unwrap()
        };

        miner_configs.workspace.node_home.push(NODE_HOME);
        miner_configs.profile.auth_key = authkey.to_string();
        miner_configs.profile.account = account;

        fs::create_dir_all(&miner_configs.workspace.node_home).unwrap();
        let toml = toml::to_string(&miner_configs).unwrap();
        let home_path = miner_configs.workspace.node_home.clone();
        let miner_toml_path = home_path.join(CONFIG_FILE);
        let file = fs::File::create(&miner_toml_path);
        file.unwrap().write(&toml.as_bytes())
            .expect("Could not write toml file");

        println!("\nminer app initialized, file saved to: {:?}", &miner_toml_path);
        miner_configs
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

/// Miner profile to commit this work chain to a particular identity
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Profile {
    ///The 0L account for the Miner and prospective validator. This is derived from auth_key
    pub account: AccountAddress,

    ///Miner Authorization Key for 0L Blockchain. Note: not the same as public key, nor account.
    pub auth_key: String,
    /// URL for submitting txs to
    pub url: String,
    /// Waypoint from which the client will sync
    pub waypoint: Waypoint,
    /// Max gas units to pay per transaction
    pub max_gas_unit_for_tx: u64, //1_000_000,
    /// Max coin price per unit of gas
    pub coin_price_per_unit: u64, //1, // in micro_gas
    /// Time in milliseconds to timeout
    pub user_tx_timeout: u64, // 5_000,

}

impl Default for Profile {
    fn default() -> Self {
        Self {
            auth_key: "".to_owned(),
            account: AccountAddress::from_hex_literal("0x0").unwrap(),
            url: "http://localhost:8080".to_owned(),
            waypoint: "0:732ea2e1c3c5ee892da11abcd1211f22c06b5cf75fd6d47a9492c21dbfc32a46".parse::<Waypoint>().unwrap(),
            max_gas_unit_for_tx: 1_000_000,
            coin_price_per_unit: 1, // in micro_gas
            user_tx_timeout: 5_000,
        }
    }
}
