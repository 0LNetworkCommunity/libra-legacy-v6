// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use anyhow::{ensure, Result};
use rand::{rngs::StdRng, SeedableRng};
use serde::{de::DeserializeOwned, Deserialize, Serialize};
use std::{
    collections::HashSet,
    fmt,
    fs::File,
    io::{Read, Write},
    path::{Path, PathBuf},
    str::FromStr,
};
use thiserror::Error;
use std::env;

// use hex;

mod admission_control_config;
pub use admission_control_config::*;
mod rpc_config;
pub use rpc_config::*;
mod consensus_config;
pub use consensus_config::*;
mod debug_interface_config;
pub use debug_interface_config::*;
mod execution_config;
pub use execution_config::*;
mod key_manager_config;
pub use key_manager_config::*;
mod logger_config;
pub use logger_config::*;
mod metrics_config;
pub use metrics_config::*;
mod mempool_config;
pub use mempool_config::*;
mod network_config;
pub use network_config::*;
mod secure_backend_config;
pub use secure_backend_config::*;
mod state_sync_config;
pub use state_sync_config::*;
mod storage_config;
pub use storage_config::*;
mod safety_rules_config;
pub use safety_rules_config::*;
mod upstream_config;
pub use upstream_config::*;
mod test_config;
use crate::network_id::NetworkId;
use libra_types::waypoint::Waypoint;
pub use test_config::*;

/// Config pulls in configuration information from the config file.
/// This is used to set up the nodes and configure various parameters.
/// The config file is broken up into sections for each module
/// so that only that module can be passed around
#[cfg_attr(any(test, feature = "fuzzing"), derive(Clone, PartialEq))]
#[derive(Debug, Default, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct NodeConfig {
    #[serde(default)]
    pub admission_control: AdmissionControlConfig,
    #[serde(default)]
    pub rpc: RpcConfig,
    #[serde(default)]
    pub base: BaseConfig,
    #[serde(default)]
    pub consensus: ConsensusConfig,
    #[serde(default)]
    pub debug_interface: DebugInterfaceConfig,
    #[serde(default)]
    pub execution: ExecutionConfig,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub full_node_networks: Vec<NetworkConfig>,
    #[serde(default)]
    pub logger: LoggerConfig,
    #[serde(default)]
    pub metrics: MetricsConfig,
    #[serde(default)]
    pub mempool: MempoolConfig,
    #[serde(default)]
    pub state_sync: StateSyncConfig,
    #[serde(default)]
    pub storage: StorageConfig,
    #[serde(default)]
    pub test: Option<TestConfig>,
    #[serde(default)]
    pub upstream: UpstreamConfig,
    #[serde(default)]
    pub validator_network: Option<NetworkConfig>,
    #[serde(default)]
    pub miner_swarm_fixture: Option<GenesisMiningProof>
}

// 0L Change: Necessary for genesis transaction.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct GenesisMiningProof {
    pub preimage: String,
    pub proof: String,
}



impl Default for GenesisMiningProof {
    fn default() -> GenesisMiningProof {
        let node_env = match env::var("NODE_ENV") {
            Ok(val) => val,
            _ => "test".to_string() // default to "test" if not set
        };

        // These use "alice" fixtures from ../fixtures and used elsewhere in the project, in both easy(stage) and hard(Prod) mode.
        //TODO: These fixtures should be moved to /fixtures/miner_fixtures.rs

        let easy_preimage = "f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

        let easy_proof = "0000b20d390731ea0f4405e112809c18d7959a2421a54f77039c13dfd26d3170766ec4d969fd0b70c5f9c674c591a70974d2ce1198c03bedcd905442bc1177d9740c2097cff7c8081e46da4c1e4241201ce44dc99c446b03afec3d238c5263ac453fe36210664e39c4268a07d283db83a22b708fc9224408c5081f92ad13facd154145bbc514170c7dbe549b8f823a2c520f576dedf509f6ddfdd71550e988ad3af3df5be3c8524468b81dc886b7a91af98dce36eb2e07805e23adb843535dc8f88016e898d87f1d7dce9735ccb49398b083aefa3f19c1df4b0e85996bd22a1ba0a7d31dacae958828e808695e715d661b03e7347fef5367d55298b29cb94214b8ffffbf8e84a14e83de7697db052c5dddd3563084eb89fd35b39509f757e5f4f8151fee794773f053f9352a8aa63842509c5dfae4e82dc8e6f80840e63db891b16438f4e64f6743be1f94ea5bca0662340f3d2199ccc5150a8fc2bf9d910b54c73cd1321cb706e6c854132c0b1523bc4e630344f43f035f3b41eee17a7bce271234d3802a46781869dcb6f7a7056b52222ec383a4fda755b10eb8eb95b36189a3b7eb3fc2f35070bb625138e0ce6a169243339e136dfade1d4205151ac5a7a2b8f1ae2e4207a760470c353cecc205a05773eb85499f29c61e558fcdd0f0a6db828d506d7e2acb022899803156135bde344fea9734d9d295fbc4aa43864dab6a938300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001".to_owned();

        //NOTE: this is same as easy_preimage
        // let hard_preimage = easy_preimage.to_owned();
        let hard_preimage = "f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c009f240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

        let hard_proof =  "001f82a9582dfc54369c4ceb21062151b8f9e493dec76112b5ead760dc18f6e91fe202722f607f3f71ea4cee29ed39a50f28ece9fb502dbf022bff67427bb42a57a6d6ab2d4072da8f0e6f2d540289bd563a0130aff9cae95719df71847dea56f3c541d022d00bfbbf046c65fd810ff9cf5ffd3a6a1b492ccdc3de7889bd16058e6dbcc67e4900ba9d884dd00342591d41ce0e1a4d60999c867799468423183c76c795b5d3ea5be253eb65a8f4016790aa8299f4dd40d116982d76d5eb54c263a13b58bf5ddc297fa2ec4d9a4464a05bed4408548f64d465fc9bdc9891b0f8ef62c08aefd24fe76d956a8e3ba1dd5ebacb3808c257bc36a5f8632c444af8193363fff0087ae2e864d653df2dcf69fd6fd253ee07904adac1dc2d5418066be127ad186f5622a7ca15fe3471f282f43a201b8addd2d951afce908d9fcf3b5ca9ee09c6cf3e6784b9b186f020b6083af1968bd95ff49694ee07c6dca6e7a84b4eb3a7e6a9447dbc8bd2d2f5a123283322e3b4a8c31200bc61fdf0c4fe392119de819f158d8bef561807c55933259fdefa24810e92116aa054ca6392a70e00d60fb63ecbcfe80750d62f344fc1773aa76248d2c3907aa9b1b582d788327cf118f9e7ccc8bae2da547654fa67acafbd2479ba2ab932f299ce35cd3db99ba4d5ea4e6d29568e2121023ec685255996fe76599f6e1d2fe2be0ad02b0182b8b6a410cdde9bd700572851f862be5e9fa8469a3ca4a8770a8da9efdb36f51e110979c074189bedd9f79e67fd81e9626ceac2f0b181f98a39080b1921bea0e09be513227b85422bf51319d3bdf658b5eb395d32e09d23c6bfab5a44523529d03c73b2bf806d7923fcc8d76101d90844527d3a7697559c3e9e49fb1b13fa5471e30a3e9c06018c14dc89ea22769fcaa2d707fd1e9d022cadb115c02f0e03cffe2c8165061f3fc49f83adc04bc462c5b156f0b35a17fa0ca9a84bafe42bda92c7f6dea57f03a67b60e14a2b9c28ca30199305e6c8e6192adcb5e8957314ab71c50772655a33801bf25c2406f65016a2695e59f824173272611637fa3ec4fae6f1b91a439681bf2ec2a3ffc2493891497c5f7db03d3f6350f9d3b59bacb0332061ec918c78125777074d9b02c54fccbb6d5d4fb3c355b57d6fac89d3aeb9ef88d4b568d30795c15233db9cf2bcd5eb967c7b35690f75cb74484e34a1ff0e2eec44a0d971573964f9c3376b3cf52deaed62c3c4b1166e496bfa8ac7c150fc7009800773de60ffa93950c6759558a18f00795b68f901336dfdecce1c53a1f0f277b1dd3e5176047505c18e5da93e2714749eceaffd80b2f574e4715a24f331d3d128f13f547b26114c24d5862480a6fe63b3c7becdb85326a91fcad24ab093f53766c387aa66c0235244299d4fb7ed131d216972300c0090a107de40ae4dde86b50d360b5f581f76d2f53d93".to_owned();

        if node_env == "prod"  {
            return GenesisMiningProof {
                preimage: hard_preimage,
                proof: hard_proof,

            }
        } else {
            return GenesisMiningProof {
                preimage: easy_preimage,
                proof: easy_proof,
            }
        }

    }
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(default, deny_unknown_fields)]
pub struct BaseConfig {
    data_dir: PathBuf,
    pub role: RoleType,
    pub waypoint: WaypointConfig,
}

impl Default for BaseConfig {
    fn default() -> BaseConfig {
        BaseConfig {
            data_dir: PathBuf::from("./"),
            role: RoleType::Validator,
            waypoint: WaypointConfig::None,
        }
    }
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "snake_case", tag = "type")]
pub enum WaypointConfig {
    FromConfig { waypoint: Waypoint },
    FromStorage { backend: SecureBackend },
    None,
}

impl WaypointConfig {
    pub fn waypoint_from_config(&self) -> Option<Waypoint> {
        if let WaypointConfig::FromConfig { waypoint } = self {
            Some(*waypoint)
        } else {
            None
        }
    }
}

#[derive(Clone, Copy, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum RoleType {
    Validator,
    FullNode,
}

impl RoleType {
    pub fn is_validator(self) -> bool {
        self == RoleType::Validator
    }

    pub fn as_str(self) -> &'static str {
        match self {
            RoleType::Validator => "validator",
            RoleType::FullNode => "full_node",
        }
    }
}

impl FromStr for RoleType {
    type Err = ParseRoleError;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "validator" => Ok(RoleType::Validator),
            "full_node" => Ok(RoleType::FullNode),
            _ => Err(ParseRoleError(s.to_string())),
        }
    }
}

impl fmt::Display for RoleType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

#[derive(Debug, Error)]
#[error("Invalid node role: {0}")]
pub struct ParseRoleError(String);

impl NodeConfig {
    pub fn data_dir(&self) -> &PathBuf {
        &self.base.data_dir
    }

    pub fn set_data_dir(&mut self, data_dir: PathBuf) {
        self.base.data_dir = data_dir.clone();
        self.consensus.set_data_dir(data_dir.clone());
        self.metrics.set_data_dir(data_dir.clone());
        self.storage.set_data_dir(data_dir);
    }

    /// This clones the underlying data except for the keys so that this config can be used as a
    /// template for another config.
    pub fn clone_for_template(&self) -> Self {
        Self {
            admission_control: self.admission_control.clone(),
            rpc: self.rpc.clone(),
            base: self.base.clone(),
            consensus: self.consensus.clone(),
            debug_interface: self.debug_interface.clone(),
            execution: self.execution.clone(),
            full_node_networks: self
                .full_node_networks
                .iter()
                .map(|c| c.clone_for_template())
                .collect(),
            logger: self.logger.clone(),
            metrics: self.metrics.clone(),
            mempool: self.mempool.clone(),
            state_sync: self.state_sync.clone(),
            storage: self.storage.clone(),
            test: None,
            upstream: self.upstream.clone(),
            validator_network: self
                .validator_network
                .as_ref()
                .map(|n| n.clone_for_template()),
            miner_swarm_fixture: self.miner_swarm_fixture.clone() // 0L change.
        }
    }

    /// Reads the config file and returns the configuration object in addition to doing some
    /// post-processing of the config
    /// Paths used in the config are either absolute or relative to the config location
    pub fn load<P: AsRef<Path>>(input_path: P) -> Result<Self> {
        let mut config = Self::load_config(&input_path)?;
        if config.base.role.is_validator() {
            ensure!(
                config.validator_network.is_some(),
                "Missing a validator network config for a validator node"
            );
        } else {
            ensure!(
                config.validator_network.is_none(),
                "Provided a validator network config for a full_node node"
            );
        }

        let mut network_ids = HashSet::new();
        let input_dir = RootPath::new(input_path);
        config.execution.load(&input_dir)?;
        if let Some(network) = &mut config.validator_network {
            network.load(&input_dir, RoleType::Validator)?;
            network_ids.insert(network.network_id.clone());
        }
        for network in &mut config.full_node_networks {
            network.load(&input_dir, RoleType::FullNode)?;

            // Validate that a network isn't repeated
            let network_id = network.network_id.clone();
            ensure!(
                !network_ids.contains(&network_id),
                format!("network_id {:?} was repeated", network_id)
            );
            network_ids.insert(network_id);
        }
        config.set_data_dir(config.data_dir().clone());
        Ok(config)
    }

    pub fn save<P: AsRef<Path>>(&mut self, output_path: P) -> Result<()> {
        println!("NodeConfig save 0");
        let output_dir = RootPath::new(&output_path);
        self.execution.save(&output_dir)?;
        println!("NodeConfig save 1");

        if let Some(network) = &mut self.validator_network {
            println!("NodeConfig save 2");

            network.save(&output_dir)?;
        }
        for network in &mut self.full_node_networks {
            println!("NodeConfig save 3");

            network.save(&output_dir)?;
        }
        // This must be last as calling save on subconfigs may change their fields
        println!("NodeConfig save 4");

        self.save_config(&output_path)?;
        println!("NodeConfig save 5");

        Ok(())
    }

    pub fn randomize_ports(&mut self) {
        self.admission_control.randomize_ports();
        self.debug_interface.randomize_ports();
        self.storage.randomize_ports();
        self.rpc.randomize_ports();

        if let Some(network) = self.validator_network.as_mut() {
            network.listen_address = crate::utils::get_available_port_in_multiaddr(true);
            network.advertised_address = network.listen_address.clone();
        }

        for network in self.full_node_networks.iter_mut() {
            network.listen_address = crate::utils::get_available_port_in_multiaddr(true);
            network.advertised_address = network.listen_address.clone();
        }
    }

    pub fn random() -> Self {
        let mut rng = StdRng::from_seed([0u8; 32]);
        Self::random_with_rng(&mut rng)
    }

    pub fn random_with_rng(rng: &mut StdRng) -> Self {
        let mut config = NodeConfig::default();
        config.random_internal(rng);
        config
    }

    pub fn random_with_template(template: &Self, rng: &mut StdRng) -> Self {
        let mut config = template.clone_for_template();
        config.random_internal(rng);
        config
    }

    fn random_internal(&mut self, rng: &mut StdRng) {
        let mut test = TestConfig::new_with_temp_dir();
        if self.base.role == RoleType::Validator {

            test.initialize_storage = true;
            test.random_account_key(rng);
            let peer_id = libra_types::account_address::from_public_key(
                &test.operator_keypair.as_ref().unwrap().public_key(),
            );

            if self.validator_network.is_none() {
                let network_config = NetworkConfig::network_with_id(NetworkId::Validator);
                self.validator_network = Some(network_config);
            }

            let validator_network = self.validator_network.as_mut().unwrap();
            validator_network.random_with_peer_id(rng, Some(peer_id));
            test.random_consensus_key(rng);
        } else {
            self.validator_network = None;
            if self.full_node_networks.is_empty() {
                let network_config = NetworkConfig::network_with_id(NetworkId::Public);
                self.full_node_networks.push(network_config);
            }
            for network in &mut self.full_node_networks {
                network.random(rng);
            }
        }
        self.set_data_dir(test.temp_dir().unwrap().to_path_buf());
        self.test = Some(test);
    }
}

pub trait PersistableConfig: Serialize + DeserializeOwned {
    fn load_config<P: AsRef<Path>>(path: P) -> Result<Self> {
        let mut file = File::open(&path)?;
        let mut contents = String::new();
        file.read_to_string(&mut contents)?;
        Self::parse(&contents)
    }

    fn save_config<P: AsRef<Path>>(&self, output_file: P) -> Result<()> {
        let contents = toml::to_vec(&self)?;
        let mut file = File::create(output_file)?;

        file.write_all(&contents)?;

        // @TODO This causes a major perf regression that needs to be evaluated before enabling
        // file.sync_all()?;
        Ok(())
    }

    fn parse(serialized: &str) -> Result<Self> {
        Ok(toml::from_str(&serialized)?)
    }
}

impl<T: ?Sized> PersistableConfig for T where T: Serialize + DeserializeOwned {}

#[derive(Debug)]
pub struct RootPath {
    root_path: PathBuf,
}

impl RootPath {
    pub fn new<P: AsRef<Path>>(path: P) -> Self {
        let root_path = if let Some(parent) = path.as_ref().parent() {
            parent.to_path_buf()
        } else {
            PathBuf::from("")
        };

        Self { root_path }
    }

    /// This function assumes that the path is already a directory
    pub fn new_path<P: AsRef<Path>>(path: P) -> Self {
        let root_path = path.as_ref().to_path_buf();
        Self { root_path }
    }

    /// This adds a full path when loading / storing if one is not specified
    pub fn full_path(&self, file_path: &PathBuf) -> PathBuf {
        if file_path.is_relative() {
            self.root_path.join(file_path)
        } else {
            file_path.clone()
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    const DEFAULT: &str = "src/config/test_data/single.node.config.toml";
    const RANDOM_DEFAULT: &str = "src/config/test_data/random.default.node.config.toml";
    const RANDOM_COMPLETE: &str = "src/config/test_data/random.complete.node.config.toml";

    #[test]
    fn verify_default_config() {
        // This test likely failed because there was a breaking change in the NodeConfig. It may be
        // desirable to reverse the change or to change the test config and potentially documentation.
        let mut actual = NodeConfig::random();
        let mut expected = NodeConfig::load(DEFAULT).expect("Unable to load config");

        // These are randomly generated, so let's force them to be the same, perhaps we can use a
        // random seed so that these can be made uniform...
        let actual_network = actual
            .validator_network
            .as_mut()
            .expect("Missing actual network config");
        let expected_network = expected
            .validator_network
            .as_mut()
            .expect("Missing expected network config");

        expected_network.advertised_address = actual_network.advertised_address.clone();
        expected_network.listen_address = actual_network.listen_address.clone();
        expected_network.identity = actual_network.identity.clone();
        expected_network.network_peers = actual_network.network_peers.clone();
        expected_network.seed_peers = actual_network.seed_peers.clone();
        expected_network.seed_peers_file = actual_network.seed_peers_file.clone();

        expected.set_data_dir(actual.data_dir().clone());
        compare_configs(&actual, &expected);
    }

    #[test]
    fn verify_random_complete_config() {
        let mut rng = StdRng::from_seed([255u8; 32]);
        let mut expected = NodeConfig::random_with_rng(&mut rng);

        // Update paths after save
        let root_dir = RootPath::new(expected.test.as_ref().unwrap().temp_dir().unwrap());
        let path = root_dir.full_path(&PathBuf::from("node.config.toml"));
        expected.save(&path).expect("Unable to save config");

        let actual = NodeConfig::load(RANDOM_COMPLETE).expect("Unable to load config");
        expected.set_data_dir(actual.data_dir().clone());
        compare_configs(&actual, &expected);
    }

    #[test]
    fn verify_random_default_config() {
        let mut rng = StdRng::from_seed([255u8; 32]);
        let mut expected = NodeConfig::random_with_rng(&mut rng);

        // Update paths after save
        let root_dir = RootPath::new(expected.test.as_ref().unwrap().temp_dir().unwrap());
        let path = root_dir.full_path(&PathBuf::from("node.config.toml"));
        expected.save(&path).expect("Unable to save config");

        let actual = NodeConfig::load(RANDOM_DEFAULT).expect("Unable to load config");
        expected.set_data_dir(actual.data_dir().clone());
        compare_configs(&actual, &expected);
    }

    fn compare_configs(actual: &NodeConfig, expected: &NodeConfig) {
        // This is broken down first into smaller evaluations to improve identifying what is broken.
        // The output for a broken config leveraging assert at the top level config is not readable.
        assert_eq!(actual.admission_control, expected.admission_control);
        assert_eq!(actual.base, expected.base);
        assert_eq!(actual.consensus, expected.consensus);
        assert_eq!(actual.debug_interface, expected.debug_interface);
        assert_eq!(actual.execution, expected.execution);
        assert_eq!(actual.full_node_networks, expected.full_node_networks);
        assert_eq!(actual.full_node_networks.len(), 0);
        assert_eq!(actual.logger, expected.logger);
        assert_eq!(actual.mempool, expected.mempool);
        assert_eq!(actual.metrics, expected.metrics);
        assert_eq!(actual.state_sync, expected.state_sync);
        assert_eq!(actual.storage, expected.storage);
        assert_eq!(actual.test, expected.test);
        assert_eq!(actual.validator_network, expected.validator_network);
        assert_eq!(actual, expected);
    }

    #[test]
    fn verify_all_configs() {
        let _ = vec![
            // This contains all the default fields written to disk, it verifies that the default
            // is consistent and can be loaded without failure
            DEFAULT,
            // This config leverages default fields but uses the same PeerId and secondary files as
            // the random.complete.node.config.toml. It verifies the assumptions about loading
            // files even if the paths aren't present
            RANDOM_DEFAULT,
            // This config explicitly writes all the default values for a random peer to disk and
            // verifies that it correctly loads. It shares the same PeerId as
            // random.default.node.config.toml
            RANDOM_COMPLETE,
        ]
        .iter()
        .map(|path| {
            NodeConfig::load(PathBuf::from(path)).unwrap_or_else(|_| panic!("Error in {}", path))
        })
        .collect::<Vec<_>>();
    }

    #[test]
    fn verify_role_type_conversion() {
        // Verify relationship between RoleType and as_string() is reflexive
        let validator = RoleType::Validator;
        let full_node = RoleType::FullNode;
        let converted_validator = RoleType::from_str(validator.as_str()).unwrap();
        let converted_full_node = RoleType::from_str(full_node.as_str()).unwrap();
        assert_eq!(converted_validator, validator);
        assert_eq!(converted_full_node, full_node);
    }

    #[test]
    // TODO(joshlind): once the 'matches' crate becomes stable, clean this test up!
    fn verify_parse_role_error_on_invalid_role() {
        let invalid_role_type = "this is not a valid role type";
        match RoleType::from_str(invalid_role_type) {
            Err(ParseRoleError(_)) => { /* the expected error was thrown! */ }
            _ => panic!("A ParseRoleError should have been thrown on the invalid role type!"),
        }
    }
}
