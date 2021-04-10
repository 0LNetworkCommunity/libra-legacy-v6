//! OlCli Config

// use miner::delay::delay_difficulty;
// use miner::submit_tx::TxParams;
use crate::{commands::CONFIG_FILE, entrypoint};
use abscissa_core::path::PathBuf;
use dirs;
use libra_global_constants::NODE_HOME;
use libra_types::{
    account_address::AccountAddress, transaction::authenticator::AuthenticationKey,
    waypoint::Waypoint,
};
use machine_ip;
use reqwest::Url;
use rustyline::Editor;
use serde::{Deserialize, Serialize};
use std::io::Write;
use std::{fs, net::Ipv4Addr, str::FromStr};

const BASE_WAYPOINT: &str = "0:683185844ef67e5c8eeaa158e635de2a4c574ce7bbb7f41f787d38db2d623ae2";
/// MinerApp Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct OlCliConfig {
    /// Workspace config
    pub workspace: Workspace,
    /// User Profile
    pub profile: Profile,
    /// Chain Info for all users
    pub chain_info: ChainInfo,
    /// Transaction configurations
    pub tx_configs: TxTypes,
}

impl OlCliConfig {
    /// Gets the dynamic waypoint from libra node's key_store.json
    pub fn get_waypoint(&self) -> Option<Waypoint> {
        match fs::File::open(self.get_key_store_path()) {
            Ok(file) => {
                let json: serde_json::Value =
                    serde_json::from_reader(file).expect("could not parse JSON in key_store.json");
                match ajson::get(&json.to_string(), "*/waypoint.value") {
                    Some(value) => Some(value.to_string().parse().unwrap()),
                    // If nothing is found in key_store.json fallback to base_waypoint in toml
                    _ => self.chain_info.base_waypoint,
                }
            }
            Err(_err) => self.chain_info.base_waypoint,
        }
    }

    /// Get where the block/proofs are stored.
    pub fn get_block_dir(&self) -> PathBuf {
        let mut home = self.workspace.node_home.clone();
        home.push(&self.workspace.block_dir);
        home
    }

    /// Get where node key_store.json stored.
    pub fn get_key_store_path(&self) -> PathBuf {
        let mut home = self.workspace.node_home.clone();
        home.push("key_store.json");
        home
    }

    /// Get where node key_store.json stored.
    pub fn init_miner_configs(
        authkey: AuthenticationKey,
        account: AccountAddress,
        config_path: &Option<PathBuf>,
        swarm_path: &Option<PathBuf>
    ) -> OlCliConfig {
        // TODO: Check if configs exist and warn on overwrite.
        let mut miner_configs = OlCliConfig::default();

        miner_configs.workspace.node_home = if config_path.is_some() {
            config_path.clone().unwrap()
        } else {
            dirs::home_dir().unwrap()
        };

        miner_configs.workspace.node_home.push(NODE_HOME);

        fs::create_dir_all(&miner_configs.workspace.node_home).unwrap();
        // Set up github token
        let mut rl = Editor::<()>::new();

        let system_ip = machine_ip::get().unwrap().to_string();
        // println!("\nFound host IP address: {:?}\n", system_ip);

        // TODO: Use `dialoguer` for this
        let ip = match rl.readline(&format!(
            "Will you use this host, and this IP address {:?}, for your node? (y/n) ",
            system_ip
        )) {
            Ok(val) => {
                if (val == "y") | (val == "Y") {
                    system_ip
                        .parse::<Ipv4Addr>()
                        .expect("Could not parse IP address: {:?}")
                } else {
                    let readline = rl
                        .readline("Enter the IP address of the node: ")
                        .expect("Must enter an ip address, or 0.0.0.0 as localhost");

                    readline
                        .parse::<Ipv4Addr>()
                        .expect("Could not parse IP address")
                }
            }
            Err(_) => {
                std::process::exit(1);
            }
        };

        miner_configs.profile.ip = ip;

        // Get optional statement which goes into genesis block
        miner_configs.profile.statement = rl
            .readline("Enter a (fun) statement to go into your first transaction: ")
            .expect(
                "Please enter some text unique to you which will go into your block 0 preimage.",
            );

        miner_configs.profile.auth_key = authkey.to_string();
        miner_configs.profile.account = account;
        
        if swarm_path.is_some() {
          miner_configs.profile.default_node = get_tx_params_from_swarm(entry_args.swarm_path.unwrap()).url;
        }

        let toml = toml::to_string(&miner_configs).unwrap();
        let home_path = miner_configs.workspace.node_home.clone();
        let miner_toml_path = home_path.join(CONFIG_FILE);
        let file = fs::File::create(&miner_toml_path);
        file.unwrap()
            .write(&toml.as_bytes())
            .expect("Could not write toml file");

        println!(
            "\nminer app initialized, file saved to: {:?}",
            &miner_toml_path
        );
        miner_configs
    }
}

/// Default configuration settings.
///
/// Note: if your needs are as simple as below, you can
/// use `#[derive(Default)]` on OlCliConfig instead.
impl Default for OlCliConfig {
    fn default() -> Self {
        Self {
            workspace: Workspace::default(),
            profile: Profile::default(),
            chain_info: ChainInfo::default(),
            tx_configs: TxTypes::default(),
        }
    }
}

/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Workspace {
    /// home directory of the libra node, may be the same as miner.
    pub node_home: PathBuf,
    /// Directory to store blocks in
    pub block_dir: String,

    /// Path to which stdlib binaries for upgrades get built typically /language/stdlib/staged/stdlib.mv
    pub stdlib_bin_path: PathBuf,
}

impl Default for Workspace {
    fn default() -> Self {
        Self {
            node_home: dirs::home_dir().unwrap().join(NODE_HOME),
            block_dir: "blocks".to_owned(),
            stdlib_bin_path: "/root/libra/language/stdlib/staged/stdlib.mv"
                .parse::<PathBuf>()
                .unwrap(),
        }
    }
}

/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct ChainInfo {
    /// Chain that this work is being committed to
    pub chain_id: String,

    /// Waypoint for last epoch which the node is syncing from.
    pub base_waypoint: Option<Waypoint>,
}

// TODO: These defaults serving as test fixtures.
impl Default for ChainInfo {
    fn default() -> Self {
        Self {
            chain_id: "experimental".to_owned(),
            // Mock Waypoint. Miner complains without.
            base_waypoint: Waypoint::from_str(BASE_WAYPOINT).ok(),
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

    ///An opportunity for the Miner to write a message on their genesis block.
    pub statement: String,

    /// ip address of this node. May be different from transaction URL.
    pub ip: Ipv4Addr,

    /// Node URL and and port to submit transactions. Defaults to localhost:8080
    pub default_node: Option<Url>,

    /// Other nodes to connect for fallback connections
    pub upstream_nodes: Option<Vec<Url>>,
}

impl Default for Profile {
    fn default() -> Self {
        Self {
            auth_key: "".to_owned(),
            account: AccountAddress::from_hex_literal("0x0").unwrap(),
            statement: "Protests rage across the nation".to_owned(),
            ip: "0.0.0.0".parse().unwrap(),
            default_node: Some("http://localhost:8080".parse().expect("parse url")),
            upstream_nodes: Some(vec!["http://localhost:8080"
                .parse()
                .expect("parse url")]),
        }
    }
}
/// Transaction types used in 0L clients
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct TxTypes {
    /// Transactions related to management: val configs, onboarding, upgrade
    pub management_txs: TxPrefs,
    /// Transactions related to mining: commit proof.
    pub miner_txs: TxPrefs,
}

/// Transaction preferences for a given type of transaction
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct TxPrefs {
    /// Max gas units to pay per transaction
    pub max_gas_unit_for_tx: u64, // gas UNITS of computation
    /// Max coin price per unit of gas
    pub coin_price_per_unit: u64, // price in micro GAS
    /// Time in milliseconds to timeout
    pub user_tx_timeout: u64, // milliseconds,
}

impl Default for TxTypes {
    fn default() -> Self {
        Self {
            management_txs: TxPrefs {
                max_gas_unit_for_tx: 1_000_000, // oracle upgrade transaction is expensive.
                coin_price_per_unit: 1,
                user_tx_timeout: 5_000,
            },
            miner_txs: TxPrefs {
                max_gas_unit_for_tx: 10_000, // miner transaction
                coin_price_per_unit: 1,
                user_tx_timeout: 5_000,
            },
        }
    }
}
