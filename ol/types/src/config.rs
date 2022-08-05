//! Configs for all 0L apps.

use anyhow::{bail, Error};
use diem_config::config::NodeConfig;
use diem_global_constants::{CONFIG_FILE, NODE_HOME};
use diem_types::{
    account_address::AccountAddress, chain_id::NamedChain,
    transaction::authenticator::AuthenticationKey, waypoint::Waypoint,
};
use dirs;
use once_cell::sync::Lazy;
use reqwest::{blocking::Client, Url};
use serde::{Deserialize, Serialize};
use serde_json::{self, json};
use std::{
    fs::{self, File},
    io::{Read, Write},
    net::Ipv4Addr,
    path::PathBuf,
    str::FromStr,
};

use crate::dialogue::{what_home, what_ip, what_statement, what_vfn_ip};

const BASE_WAYPOINT: &str = "0:683185844ef67e5c8eeaa158e635de2a4c574ce7bbb7f41f787d38db2d623ae2";

/// Check if we are in prod mode
pub static IS_PROD: Lazy<bool> = Lazy::new(|| {
    match std::env::var("NODE_ENV") {
        Ok(val) => {
            match val.as_str() {
                "prod" => true,
                // if anything else is set by user is false
                _ => false,
            }
        }
        // default to prod if nothig is set
        _ => true,
    }
});

// TODO: this is duplicated in ol/keys/wallet due to dependency cycle. Move to Global constants?
/// check this is CI environment
pub static IS_TEST: Lazy<bool> = Lazy::new(|| {
    // assume default if NODE_ENV=prod and TEST=y.
    std::env::var("TEST").unwrap_or("n".to_string()) != "n".to_string()
});

/// MinerApp Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct AppCfg {
    /// Workspace config
    pub workspace: Workspace,
    /// User Profile
    pub profile: Profile,
    /// Chain Info for all users
    pub chain_info: ChainInfo,
    /// Transaction configurations
    pub tx_configs: TxConfigs,
}

/// Get a AppCfg object from toml file
pub fn parse_toml(path: Option<PathBuf>) -> Result<AppCfg, Error> {
    let cfg_path = path.unwrap_or(dirs::home_dir().unwrap().join(".0L").join("0L.toml"));

    let mut toml_buf = "".to_string();
    let mut file = File::open(&cfg_path)?;
    file.read_to_string(&mut toml_buf)?;

    let cfg: AppCfg = toml::from_str(&toml_buf)?;
    Ok(cfg)
}

/// Get a AppCfg object from toml file
pub fn fix_missing_fields(path: PathBuf) -> Result<(), Error> {
    let cfg: AppCfg = parse_toml(Some(path))?;
    cfg.save_file()?;
    Ok(())
}

impl AppCfg {
    /// Gets the dynamic waypoint from diem node's key_store.json
    pub fn get_waypoint(&self, swarm_path_opt: Option<PathBuf>) -> Result<Waypoint, Error> {
        let err_msg = Error::msg("Could not get waypoint from cli, key_store.json, nor 0L.toml.");

        if let Some(path) = swarm_path_opt {
            return Ok(get_swarm_rpc_url(path).1);
        };

        match fs::File::open(self.get_key_store_path()) {
            Ok(file) => {
                let json: serde_json::Value =
                    serde_json::from_reader(file).expect("could not parse JSON in key_store.json");
                match ajson::get(&json.to_string(), "*/waypoint.value") {
                    Some(value) => value.to_string().parse(),
                    // If nothing is found in key_store.json fallback
                    // to base_waypoint in toml
                    _ => match self.chain_info.base_waypoint {
                        Some(w) => Ok(w),
                        None => Err(err_msg),
                    },
                }
            }
            Err(_) => {
                // println!("Waypoint: fallback to base_waypoint in 0L.toml");
                match self.chain_info.base_waypoint {
                    Some(w) => Ok(w),
                    None => Err(err_msg),
                }
            }
        }
    }

    /// format the standard namespace for 0L OPERATOR
    pub fn format_oper_namespace(&self) -> String {
        format!("{}-oper", self.profile.account.to_hex())
    }

    /// format the standard namespace for 0L OWNER
    pub fn format_owner_namespace(&self) -> String {
        self.profile.account.to_hex()
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
    pub fn init_app_configs(
        authkey: AuthenticationKey,
        account: AccountAddress,
        upstream_peer: &Option<Url>,
        config_path: &Option<PathBuf>,
        base_epoch: &Option<u64>,
        base_waypoint: &Option<Waypoint>,
        source_path: &Option<PathBuf>,
        statement: Option<String>,
        ip: Option<Ipv4Addr>,
        network_id: &Option<NamedChain>,
    ) -> Result<AppCfg, Error> {
        // TODO: Check if configs exist and warn on overwrite.
        let mut default_config = AppCfg::default();
        default_config.profile.auth_key = authkey;
        default_config.profile.account = account;

        // Get statement which goes into genesis block
        default_config.profile.statement = match statement {
            Some(s) => s,
            None => what_statement(),
        };

        default_config.profile.ip = match ip {
            Some(i) => i,
            None => what_ip().unwrap(),
        };

        default_config.profile.vfn_ip = match ip {
            Some(i) => Some(i),
            None => what_vfn_ip().ok(),
        };

        default_config.workspace.node_home =
            config_path.clone().unwrap_or_else(|| what_home(None, None));

        if let Some(u) = upstream_peer {
            default_config.profile.upstream_nodes = vec![u.to_owned()]
        };
        // Add link to previous tower
        // if !*IS_TEST {
        //     default_config.profile.tower_link = add_tower(&default_config);
        // }

        if let Some(id) = network_id {
            default_config.chain_info.chain_id = id.to_owned();
        };

        if source_path.is_some() {
            // let source_path = what_source();
            default_config.workspace.source_path = source_path.clone();
            default_config.workspace.stdlib_bin_path = Some(
                source_path
                    .as_ref()
                    .unwrap()
                    .join("language/diem-framework/staged/stdlib.mv"),
            );
        }

        // override from args
        if base_epoch.is_some() && base_waypoint.is_some() {
            default_config.chain_info.base_epoch = *base_epoch;
            default_config.chain_info.base_waypoint = *base_waypoint;
        } else {
            default_config.chain_info.base_epoch = None;
            default_config.chain_info.base_waypoint = None;
            println!("WARN: No --epoch or --waypoint or upstream --url passed. This should only be done at genesis. If that's not correct either pass --epoch and --waypoint as CLI args, or provide a URL to fetch this data from --upstream-peer or --template-url");
        }

        // skip questionnaire if CI
        if *IS_TEST {
            default_config.save_file()?;

            return Ok(default_config);
        }
        fs::create_dir_all(&default_config.workspace.node_home).unwrap();
        default_config.save_file()?;

        Ok(default_config)
    }

    /// Save swarm default configs to swarm path
    /// swarm_path points to the swarm_temp directory
    /// node_home to the directory of the current swarm persona
    pub fn init_app_configs_swarm(
        swarm_path: PathBuf,
        node_home: PathBuf,
        source_path: Option<PathBuf>,
    ) -> Result<AppCfg, Error> {
        // println!("init_swarm_config: {:?}", swarm_path); already logged in commands.rs
        let host_config = AppCfg::make_swarm_configs(swarm_path, node_home, source_path);
        host_config.save_file()?;
        Ok(host_config)
    }

    /// get configs from swarm
    /// swarm_path points to the swarm_temp directory
    /// node_home to the directory of the current swarm persona
    pub fn make_swarm_configs(
        swarm_path: PathBuf,
        node_home: PathBuf,
        source_path: Option<PathBuf>,
    ) -> AppCfg {
        let config_path = swarm_path.join(&node_home).join("node.yaml");
        let config = NodeConfig::load(&config_path)
            .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &config_path));

        // upstream configs
        let upstream_config_path = swarm_path.join(&node_home).join("node.yaml");
        let upstream_config = NodeConfig::load(&upstream_config_path).unwrap_or_else(|_| {
            panic!(
                "Failed to load NodeConfig from file: {:?}",
                &upstream_config_path
            )
        });
        let upstream_url = Url::parse(
            format!(
                "http://localhost:{}",
                upstream_config.json_rpc.address.port()
            )
            .as_str(),
        )
        .unwrap();
        // let waypoint = config.base.waypoint.waypoint();

        let mut cfg = AppCfg {
            workspace: Workspace::default(),
            profile: Profile::default(),
            chain_info: ChainInfo::default(),
            tx_configs: TxConfigs::default(),
        };

        let db_path = node_home.join("db");

        cfg.workspace.node_home = node_home;
        cfg.workspace.db_path = db_path;
        cfg.workspace.source_path = source_path;
        cfg.chain_info.base_waypoint = Some(config.base.waypoint.waypoint());
        cfg.profile.account = "4C613C2F4B1E67CA8D98A542EE3F59F5".parse().unwrap(); // alice
        cfg.profile.upstream_nodes = vec![upstream_url];

        cfg
    }

    /// save the config file to 0L.toml to the workspace home path
    pub fn save_file(&self) -> Result<(), Error> {
        let toml = toml::to_string(&self)?;
        let home_path = &self.workspace.node_home.clone();
        // create home path if doesn't exist, usually only in dev/ci environments.
        fs::create_dir_all(&home_path)?;
        let toml_path = home_path.join(CONFIG_FILE);
        let mut file = fs::File::create(&toml_path)?;
        file.write(&toml.as_bytes())?;

        println!(
            "\nhost configs initialized, file saved to: {:?}",
            &toml_path
        );
        Ok(())
    }
}

/// Default configuration settings.
///
/// Note: if your needs are as simple as below, you can
/// use `#[derive(Default)]` on OlCliConfig instead.
impl Default for AppCfg {
    fn default() -> Self {
        Self {
            workspace: Workspace::default(),
            profile: Profile::default(),
            chain_info: ChainInfo::default(),
            tx_configs: TxConfigs::default(),
        }
    }
}

/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
/// #[serde(deny_unknown_fields)]
pub struct Workspace {
    /// home directory of the diem node, may be the same as miner.
    pub node_home: PathBuf,
    /// Directory of source code (for developer tests only)
    pub source_path: Option<PathBuf>,
    /// Directory to store blocks in
    pub block_dir: String,
    /// Directory for the database
    #[serde(default = "default_db_path")]
    pub db_path: PathBuf,
    /// Path to which stdlib binaries for upgrades get built typically
    /// /language/diem-framework/staged/stdlib.mv
    pub stdlib_bin_path: Option<PathBuf>,
}

fn default_db_path() -> PathBuf {
    dirs::home_dir().unwrap().join(NODE_HOME).join("db")
}

impl Default for Workspace {
    fn default() -> Self {
        Self {
            node_home: dirs::home_dir().unwrap().join(NODE_HOME),
            source_path: None,
            block_dir: "vdf_proofs".to_owned(),
            db_path: default_db_path(),
            stdlib_bin_path: None,
        }
    }
}

/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct ChainInfo {
    /// Chain that this work is being committed to
    pub chain_id: NamedChain,

    /// Epoch from which the node started syncing
    pub base_epoch: Option<u64>,

    /// Waypoint from which the node started syncing
    pub base_waypoint: Option<Waypoint>,
}

// TODO: These defaults serving as test fixtures.
impl Default for ChainInfo {
    fn default() -> Self {
        Self {
            chain_id: NamedChain::MAINNET,
            base_epoch: Some(0),
            // Mock Waypoint. Miner complains without.
            base_waypoint: Waypoint::from_str(BASE_WAYPOINT).ok(),
        }
    }
}

/// Miner profile to commit this work chain to a particular identity
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct Profile {
    /// The 0L account for the Miner and prospective validator. This is derived from auth_key
    pub account: AccountAddress,

    /// Miner Authorization Key for 0L Blockchain. Note: not the same as public key, nor account.
    pub auth_key: AuthenticationKey,

    /// An opportunity for the Miner to write a message on their genesis block.
    pub statement: String,

    /// ip address of this node. May be different from transaction URL.
    pub ip: Ipv4Addr,

    /// ip address of the validator fullnodee
    pub vfn_ip: Option<Ipv4Addr>,

    // /// Node URL and and port to submit transactions. Defaults to localhost:8080
    // pub default_node: Option<Url>,
    /// Other nodes to connect for fallback connections
    pub upstream_nodes: Vec<Url>,

    /// Link to another delay tower.
    pub tower_link: Option<String>,
}

impl Default for Profile {
    fn default() -> Self {
        Self {
            account: AccountAddress::from_hex_literal("0x0").unwrap(),
            auth_key: AuthenticationKey::from_str(
                "0000000000000000000000000000000000000000000000000000000000000000",
            )
            .unwrap(),
            statement: "Protests rage across the nation".to_owned(),
            ip: "0.0.0.0".parse().unwrap(),
            vfn_ip: "0.0.0.0".parse().ok(),
            // default_node: Some("http://localhost:8080".parse().expect("parse url")),
            upstream_nodes: vec!["http://localhost:8080".parse().expect("parse url")],
            tower_link: None,
        }
    }
}

/// Transaction types
pub enum TxType {
    /// critical txs
    Critical,
    /// management txs
    Mgmt,
    /// miner txs
    Miner,
    /// cheap txs
    Cheap,
}

/// Transaction types used in 0L clients
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct TxConfigs {
    /// baseline cost
    #[serde(default = "default_baseline_cost")]
    pub baseline_cost: TxCost,
    /// critical transactions cost
    #[serde(default = "default_critical_txs_cost")]
    pub critical_txs_cost: Option<TxCost>,
    /// management transactions cost
    #[serde(default = "default_management_txs_cost")]
    pub management_txs_cost: Option<TxCost>,
    /// Miner transactions cost
    #[serde(default = "default_miner_txs_cost")]
    pub miner_txs_cost: Option<TxCost>,
    /// Cheap or test transation costs
    #[serde(default = "default_cheap_txs_cost")]
    pub cheap_txs_cost: Option<TxCost>,
}

impl TxConfigs {
    /// get the user txs cost preferences for given transaction type
    pub fn get_cost(&self, tx_type: TxType) -> TxCost {
        let ref baseline = self.baseline_cost.clone();
        let cost = match tx_type {
            TxType::Critical => self.critical_txs_cost.as_ref().unwrap_or_else(|| baseline),
            TxType::Mgmt => self
                .management_txs_cost
                .as_ref()
                .unwrap_or_else(|| baseline),
            TxType::Miner => self.miner_txs_cost.as_ref().unwrap_or_else(|| baseline),
            TxType::Cheap => self.cheap_txs_cost.as_ref().unwrap_or_else(|| baseline),
        };
        cost.to_owned()
    }
}

/// Transaction preferences for a given type of transaction
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct TxCost {
    /// Max gas units to pay per transaction
    pub max_gas_unit_for_tx: u64, // gas UNITS of computation
    /// Max coin price per unit of gas
    pub coin_price_per_unit: u64, // price in micro GAS
    /// Time in seconds to timeout, from now
    pub user_tx_timeout: u64, // seconds,
}

impl TxCost {
    /// create new cost object
    pub fn new(cost: u64) -> Self {
        TxCost {
            max_gas_unit_for_tx: cost, // oracle upgrade transaction is expensive.
            coin_price_per_unit: 1,
            user_tx_timeout: 5_000,
        }
    }
}
impl Default for TxConfigs {
    fn default() -> Self {
        Self {
            baseline_cost: default_baseline_cost(),
            critical_txs_cost: default_critical_txs_cost(),
            management_txs_cost: default_management_txs_cost(),
            miner_txs_cost: default_miner_txs_cost(),
            cheap_txs_cost: default_cheap_txs_cost(),
        }
    }
}

fn default_baseline_cost() -> TxCost {
    TxCost::new(10_000)
}
fn default_critical_txs_cost() -> Option<TxCost> {
    Some(TxCost::new(1_000_000))
}
fn default_management_txs_cost() -> Option<TxCost> {
    Some(TxCost::new(100_000))
}
fn default_miner_txs_cost() -> Option<TxCost> {
    Some(TxCost::new(10_000))
}
fn default_cheap_txs_cost() -> Option<TxCost> {
    Some(TxCost::new(1_000))
}

/// Get swarm configs from swarm files, swarm must be running
pub fn get_swarm_rpc_url(mut swarm_path: PathBuf) -> (Url, Waypoint) {
    swarm_path.push("0/node.yaml");
    let config = NodeConfig::load(&swarm_path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &swarm_path));

    let url = Url::parse(format!("http://localhost:{}", config.json_rpc.address.port()).as_str())
        .unwrap();
    let waypoint = config.base.waypoint.waypoint();

    (url, waypoint)
}

/// Get swarm configs from swarm files, swarm must be running
pub fn get_swarm_backup_service_url(mut swarm_path: PathBuf, swarm_id: u8) -> Result<Url, Error> {
    swarm_path.push(format!("{}/node.yaml", swarm_id));
    let config = NodeConfig::load(&swarm_path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", &swarm_path));

    let url =
        Url::parse(format!("http://localhost:{}", config.storage.address.port()).as_str()).unwrap();

    Ok(url)
}

#[derive(Serialize, Deserialize, Debug)]
struct EpochJSON {
    epoch: u64,
    waypoint: Waypoint,
}
/// fetch initial waypoint information from a clean state.
pub fn bootstrap_waypoint_from_upstream(url: &mut Url) -> Result<(u64, Waypoint), Error> {
    url.set_port(Some(3030)).unwrap();
    let epoch_url = url.join("epoch.json").unwrap();
    let g_res = reqwest::blocking::get(&epoch_url.to_string())?;
    if g_res.status().is_success() {
        let txt = g_res.text()?;
        let epoch: EpochJSON = serde_json::from_str(&txt)?;
        return Ok((epoch.epoch, epoch.waypoint));
    }
    bail!(
        "fetching remote JSON-rpc failed with status: {:?}, response: {:?}",
        g_res.status(),
        g_res.text()
    );
}

#[derive(Serialize, Deserialize, Debug)]
struct WaypointRpc {
    result: Option<serde_json::Value>,
}
/// get the waypoint from a fullnode
pub fn bootstrap_waypoint_from_rpc(url: Url) -> Result<Waypoint, Error> {
    let method = "get_waypoint_view";
    let params = json!([]);
    let request = json!({"jsonrpc": "2.0", "method": method, "params": params, "id": 1});
    let client = Client::new();
    let resp = client.post(url.as_str()).json(&request).send()?;

    // let json: WaypointRpc = serde_json::from_value(resp.json().unwrap()).unwrap();
    let parsed: serde_json::Value = resp.json()?;
    match &parsed["result"] {
        serde_json::Value::Object(r) => {
            if let serde_json::Value::String(waypoint) = &r["waypoint"] {
                let w: Waypoint = waypoint.parse()?;
                return Ok(w);
            }
        }
        _ => {}
    }
    bail!("could not get waypoint from json-rpc, url: {:?} ", url)
}
