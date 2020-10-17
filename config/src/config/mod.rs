// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use rand::{rngs::StdRng, SeedableRng};
use serde::{de::DeserializeOwned, Deserialize, Serialize};
use std::{
    collections::{HashMap, HashSet},
    fmt, fs,
    fs::File,
    io::{Read, Write},
    path::{Path, PathBuf},
    str::FromStr,
};
use thiserror::Error;
use std::env;

mod consensus_config;
pub use consensus_config::*;
mod debug_interface_config;
pub use debug_interface_config::*;
mod error;
pub use error::*;
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
mod rpc_config;
pub use rpc_config::*;
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
use libra_secure_storage::{KVStorage, Storage};
use libra_types::waypoint::Waypoint;
pub use test_config::*;

/// Config pulls in configuration information from the config file.
/// This is used to set up the nodes and configure various parameters.
/// The config file is broken up into sections for each module
/// so that only that module can be passed around
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct NodeConfig {
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
    pub rpc: RpcConfig,
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
    pub failpoints: Option<HashMap<String, String>>,
    #[serde(default)]
    pub configs_ol_miner: GenesisMiningProof
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

        // These use "alice" fixtures used elsewhere in the project, in both easy/hard mode.
        let easy_preimage = "f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

        let easy_proof = "0000b20d390731ea0f4405e112809c18d7959a2421a54f77039c13dfd26d3170766ec4d969fd0b70c5f9c674c591a70974d2ce1198c03bedcd905442bc1177d9740c2097cff7c8081e46da4c1e4241201ce44dc99c446b03afec3d238c5263ac453fe36210664e39c4268a07d283db83a22b708fc9224408c5081f92ad13facd154145bbc514170c7dbe549b8f823a2c520f576dedf509f6ddfdd71550e988ad3af3df5be3c8524468b81dc886b7a91af98dce36eb2e07805e23adb843535dc8f88016e898d87f1d7dce9735ccb49398b083aefa3f19c1df4b0e85996bd22a1ba0a7d31dacae958828e808695e715d661b03e7347fef5367d55298b29cb94214b8ffffbf8e84a14e83de7697db052c5dddd3563084eb89fd35b39509f757e5f4f8151fee794773f053f9352a8aa63842509c5dfae4e82dc8e6f80840e63db891b16438f4e64f6743be1f94ea5bca0662340f3d2199ccc5150a8fc2bf9d910b54c73cd1321cb706e6c854132c0b1523bc4e630344f43f035f3b41eee17a7bce271234d3802a46781869dcb6f7a7056b52222ec383a4fda755b10eb8eb95b36189a3b7eb3fc2f35070bb625138e0ce6a169243339e136dfade1d4205151ac5a7a2b8f1ae2e4207a760470c353cecc205a05773eb85499f29c61e558fcdd0f0a6db828d506d7e2acb022899803156135bde344fea9734d9d295fbc4aa43864dab6a938300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001".to_owned();


        let hard_preimage = "f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c009f240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

        let hard_proof =  "0053e7419eb01e955666d49a25912dd82f4d3d627aededf01478bcef332f2d68fd6238e3cc4636af163c72be8aaf65a7093a70d74d06342115b3d29f50a6eb51f310595cc7a0e2872d4cd6ecfee18020d5cde01fe8bccb451c61bd00c0932fc64e6048e3ad7b458d6250c8881af5a58a3aa42200dcd13681883bb0019e3dfa782300ef8dc00c1f83cb7fbee581a277cf8a6c9535fd5847697325c0db526d4ff1ddf7282eac92de127fbb071f49f3abb54f0c98ea6383b3764fc0dfc1b9cba71be6cda2e927882bd56cf2985db15bfa3c9117982ef97fc415ba9805b731d313b49cb53935fb6c02c91d1a2f6ebe19ef720f1e0178fa31eecdb3e1609710ea583e28004bd6683777eee6278c773a8aa2db640deee384f1304aebd09de4837c4e76ce362e2060770790b2c6f57daa263e1638dccff310cce683c7b5d86353c8550a97ee8c91142f51f0b815d4dd9fe23fd062163427523b3c45ac947edf6189ce75bbd7d07a424a7cf925a1cf7a3f9c7a46fa6eba1ab7cbc6020b9dffbf11aa14f68f74ba50576be7374ef0173caa4f4f366255467af0ec0e73b6133c572c068db9d8c8bcb54fbb3cd5e7786480e166d6e764cf719cb134d6512995150fd5b2be7189f709cf5482379edb1907b553962909f940729d48d570240c67b298c2b64d0397437880c1df3d0331811420086eed1da3fc88a43d7baf2c3f75106b78c57bb4a393002da59a4f3e1ea4fc75cc9028451f0750d6a9aabee14334c12b58bb07280287cf3454ac3c2a42c4f0f6489a253613eb13d55f2d1f5f9fd63da3c3daf75a700f3a5775914c395413696fbd967f577ad8bd0c0b91106546594c68f9fe91161c1ec7afe7275e2dc4f7d0a286f943ec41d221a020a73d586ef4731e615f6f3276382111405af6192bab0fe8c577b368543b8232614180ba5042bda4330c1e293454bfca309e22a5d33d5a97f0c1d1c2f60ad41f07254cab13a9c4c526301afe374220c3b1cb3dcaa901373a410ee9b7fc0c05a07dd8e09c700166765430fec25b286290d39e6b65b47cab5bfce98994d844b92c164702f6493b6fe9971afa91697f83001de859c1a0220ec3ebabc9551c32e795650650592694a258e63523377025c7593676e457e604025023c2676ff4198ecffa107c8c433b0f41de1944f7d8c56d37cda3ee3f446d14d379329ecbbf09b51ba4e81803388cabee334a2bb55b1336ae5a7fb80f296e03deaeac4f373d0c509c75fc946159e88c2f9251f8d25913631f49a9b1c9f0fb2580baa3aa33d0d9c6e43460a072075c30286155bbe5bc838850697afc23bf6d048913153c34b596f821db3613ae4bcaf13c50f0c32dbbd60dc83b17376265f5792594fbcfb4cd18e9acf77d6869866585fd723e182d6e75e48ba3c53e7311c8e154e8fd864b6f13ca31748447b6a33ed6822c015e21baad76b7".to_owned();

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

// 0LChange: these defaults exist only for validator_swarm_for_testing
// TODO: Remove these defaults. And warn when they are empty.

// THIS IS FOR PROD (HARD) DIFFICULTY

// impl Default for GenesisMiningProof {
//     fn default() -> GenesisMiningProof {
//         let node_env = match env::var("NODE_ENV") {
//             Ok(val) => val,
//             _ => "test".to_string() // default to "test" if not set
//         };

//         if node_env == "prod" {
//             return GenesisMiningProof {

//                 }

//             }
//                 return GenesisMiningProof {

//                 }   
// }

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
            data_dir: PathBuf::from("/opt/libra/data"),
            role: RoleType::Validator,
            waypoint: WaypointConfig::None,
        }
    }
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum WaypointConfig {
    FromConfig(Waypoint),
    FromFile(PathBuf),
    FromStorage(SecureBackend),
    None,
}

impl WaypointConfig {
    pub fn waypoint_from_config(&self) -> Option<Waypoint> {
        if let WaypointConfig::FromConfig(waypoint) = self {
            Some(*waypoint)
        } else {
            None
        }
    }

    pub fn waypoint(&self) -> Waypoint {
        let waypoint = match &self {
            WaypointConfig::FromConfig(waypoint) => Some(*waypoint),
            WaypointConfig::FromFile(path) => {
                let content = fs::read_to_string(path)
                    .unwrap_or_else(|_| panic!("Failed to read waypoint file {}", path.display()));
                Some(
                    Waypoint::from_str(&content.trim())
                        .unwrap_or_else(|_| panic!("Failed to parse waypoint: {}", content.trim())),
                )
            }
            WaypointConfig::FromStorage(backend) => {
                let storage: Storage = backend.into();
                let waypoint = storage
                    .get::<Waypoint>(libra_global_constants::WAYPOINT)
                    .expect("Unable to read waypoint")
                    .value;
                Some(waypoint)
            }
            WaypointConfig::None => None,
        };
        waypoint.expect("waypoint should be present")
    }
}

#[derive(Clone, Copy, Deserialize, Eq, PartialEq, Serialize)]
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

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "validator" => Ok(RoleType::Validator),
            "full_node" => Ok(RoleType::FullNode),
            _ => Err(ParseRoleError(s.to_string())),
        }
    }
}

impl fmt::Debug for RoleType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self)
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
        self.execution.set_data_dir(data_dir.clone());
        self.metrics.set_data_dir(data_dir.clone());
        self.storage.set_data_dir(data_dir);
    }

    /// Reads the config file and returns the configuration object in addition to doing some
    /// post-processing of the config
    /// Paths used in the config are either absolute or relative to the config location
    pub fn load<P: AsRef<Path>>(input_path: P) -> Result<Self, Error> {
        let mut config = Self::load_config(&input_path)?;
        if config.base.role.is_validator() {
            invariant(
                config.validator_network.is_some(),
                "Missing a validator network config for a validator node".into(),
            )?;
        } else {
            invariant(
                config.validator_network.is_none(),
                "Provided a validator network config for a full_node node".into(),
            )?;
        }

        let mut network_ids = HashSet::new();
        let input_dir = RootPath::new(input_path);
        config.execution.load(&input_dir)?;
        if let Some(network) = &mut config.validator_network {
            network.load(RoleType::Validator)?;
            network_ids.insert(network.network_id.clone());
        }
        for network in &mut config.full_node_networks {
            network.load(RoleType::FullNode)?;

            // Check a validator network is not included in a list of full-node networks
            let network_id = &network.network_id;
            invariant(
                !matches!(network_id, NetworkId::Validator),
                "Included a validator network in full_node_networks".into(),
            )?;
            network_ids.insert(network_id.clone());
        }
        config.set_data_dir(config.data_dir().clone());
        Ok(config)
    }

    pub fn save<P: AsRef<Path>>(&mut self, output_path: P) -> Result<(), Error> {
        let output_dir = RootPath::new(&output_path);
        self.execution.save(&output_dir)?;
        // This must be last as calling save on subconfigs may change their fields
        self.save_config(&output_path)?;
        Ok(())
    }

    pub fn randomize_ports(&mut self) {
        self.debug_interface.randomize_ports();
        self.rpc.randomize_ports();
        self.storage.randomize_ports();

        if let Some(network) = self.validator_network.as_mut() {
            network.listen_address = crate::utils::get_available_port_in_multiaddr(true);
            if let DiscoveryMethod::Gossip(config) = &mut network.discovery_method {
                config.advertised_address = network.listen_address.clone();
            }
        }

        for network in self.full_node_networks.iter_mut() {
            network.listen_address = crate::utils::get_available_port_in_multiaddr(true);
            if let DiscoveryMethod::Gossip(config) = &mut network.discovery_method {
                config.advertised_address = network.listen_address.clone();
            }
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
        let mut config = template.clone();
        config.random_internal(rng);
        config
    }

    fn random_internal(&mut self, rng: &mut StdRng) {
        let mut test = TestConfig::new_with_temp_dir();

        if self.base.role == RoleType::Validator {
            test.random_account_key(rng);
            let peer_id = libra_types::account_address::from_public_key(
                &test.owner_key.as_ref().unwrap().public_key(),
            );

            if self.validator_network.is_none() {
                let network_config = NetworkConfig::network_with_id(NetworkId::Validator);
                self.validator_network = Some(network_config);
            }

            let validator_network = self.validator_network.as_mut().unwrap();
            validator_network.random_with_peer_id(rng, Some(peer_id));
            // We want to produce this key twice
            let mut cloned_rng = rng.clone();
            test.random_execution_key(rng);

            let mut safety_rules_test_config = SafetyRulesTestConfig::new(peer_id);
            safety_rules_test_config.random_consensus_key(rng);
            safety_rules_test_config.random_execution_key(&mut cloned_rng);
            self.consensus.safety_rules.test = Some(safety_rules_test_config);
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

    #[cfg(any(test, feature = "fuzzing"))]
    pub fn default_for_public_full_node() -> Self {
        let contents = std::include_str!("test_data/public_full_node.yaml");
        let path = "default_for_public_full_node";
        Self::parse(&contents).unwrap_or_else(|e| panic!("Error in {}: {}", path, e))
    }

    #[cfg(any(test, feature = "fuzzing"))]
    pub fn default_for_validator() -> Self {
        let contents = std::include_str!("test_data/validator.yaml");
        let path = "default_for_validator";
        Self::parse(&contents).unwrap_or_else(|e| panic!("Error in {}: {}", path, e))
    }

    #[cfg(any(test, feature = "fuzzing"))]
    pub fn default_for_validator_full_node() -> Self {
        let contents = std::include_str!("test_data/validator_full_node.yaml");
        let path = "default_for_validator_full_node";
        Self::parse(&contents).unwrap_or_else(|e| panic!("Error in {}: {}", path, e))
    }
}

pub trait PersistableConfig: Serialize + DeserializeOwned {
    fn load_config<P: AsRef<Path>>(path: P) -> Result<Self, Error> {
        let mut file = File::open(&path)
            .map_err(|e| Error::IO(path.as_ref().to_str().unwrap().to_string(), e))?;
        let mut contents = String::new();
        file.read_to_string(&mut contents)
            .map_err(|e| Error::IO(path.as_ref().to_str().unwrap().to_string(), e))?;
        Self::parse(&contents)
    }

    fn save_config<P: AsRef<Path>>(&self, output_file: P) -> Result<(), Error> {
        let contents = serde_yaml::to_vec(&self)
            .map_err(|e| Error::Yaml(output_file.as_ref().to_str().unwrap().to_string(), e))?;
        let mut file = File::create(output_file.as_ref())
            .map_err(|e| Error::IO(output_file.as_ref().to_str().unwrap().to_string(), e))?;
        file.write_all(&contents)
            .map_err(|e| Error::IO(output_file.as_ref().to_str().unwrap().to_string(), e))?;
        Ok(())
    }

    fn parse(serialized: &str) -> Result<Self, Error> {
        serde_yaml::from_str(&serialized).map_err(|e| Error::Yaml("config".to_string(), e))
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

    #[test]
    fn verify_configs() {
        NodeConfig::default_for_public_full_node();
        NodeConfig::default_for_validator();
        NodeConfig::default_for_validator_full_node();

        let contents = std::include_str!("test_data/safety_rules.yaml");
        SafetyRulesConfig::parse(&contents)
            .unwrap_or_else(|e| panic!("Error in safety_rules.yaml: {}", e));
    }
}
