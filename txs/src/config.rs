//! MinerApp Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.

use std::{net::Ipv4Addr, fs};
use libra_types::{account_address::AccountAddress, transaction::authenticator::AuthenticationKey, waypoint::Waypoint};
use rustyline::Editor;
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
pub struct MinerConfig {
    /// Workspace config
    pub workspace: Workspace,
    /// User Profile
    pub profile: Profile,
    /// Chain Info for all users
    pub chain_info: ChainInfo,
}

impl MinerConfig {
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
    pub fn init_miner_configs(authkey: AuthenticationKey, account: AccountAddress, path: Option<PathBuf>) -> MinerConfig {

        // TODO: Check if configs exist and warn on overwrite.
        let mut miner_configs = MinerConfig::default();

        miner_configs.workspace.node_home = if path.is_some() {
            path.unwrap()
        } else {
            dirs::home_dir().unwrap()
        };

        miner_configs.workspace.node_home.push(NODE_HOME);
        
        fs::create_dir_all(&miner_configs.workspace.node_home).unwrap();
        // Set up github token
        let mut rl = Editor::<()>::new();

        // Get the ip address of node.
        let readline = rl.readline("IP address of your node: ").expect("Must enter an ip address, or 0.0.0.0 as localhost");
        miner_configs.profile.ip = readline.parse().expect("Could not parse IP address");
        
        // Get optional statement which goes into genesis block
        miner_configs.profile.statement = rl.readline("Enter a (fun) statement to go into your first transaction: ").expect("Please enter some text unique to you which will go into your block 0 preimage.");

        miner_configs.profile.auth_key = authkey.to_string();
        miner_configs.profile.account = account;

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
/// use `#[derive(Default)]` on MinerConfig instead.
impl Default for MinerConfig {
    fn default() -> Self {
        Self {
            workspace: Workspace::default(),
            profile: Profile::default(),
            chain_info: ChainInfo::default(),
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

/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct ChainInfo {
    /// Chain that this work is being committed to
    pub chain_id: String,
    /// Directory to store blocks in
    pub block_dir: String,
    /// Node URL and and port to submit transactions. Defaults to localhost:8080
    pub node: Option<String>,
    /// Waypoint for last epoch which the node is syncing from.
    pub base_waypoint: Option<Waypoint>,
}

// TODO: These defaults serving as test fixtures.
impl Default for ChainInfo {
    fn default() -> Self {
        Self {
            chain_id: "experimental".to_owned(),
            block_dir: "blocks".to_owned(),
            // Mock Waypoint. Miner complains without.
            base_waypoint: None,
            node: Some("http://localhost:8080".to_owned()),
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

    // ///The 0L private_key for signing transactions.
    // pub operator_private_key: Option<String>,

    /// ip address of the miner. May be different from transaction URL.
    pub ip: Ipv4Addr,

    ///An opportunity for the Miner to write a message on their genesis block.
    pub statement: String,
}

impl Default for Profile {
    fn default() -> Self {
        Self {
            auth_key: "".to_owned(),
            account: AccountAddress::from_hex_literal("0x0").unwrap(),
            ip: "0.0.0.0".parse().unwrap(),
            statement: "Protests rage across the nation".to_owned(),
        }
    }
}
