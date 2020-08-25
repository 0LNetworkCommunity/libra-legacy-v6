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
        let easy_preimage = "1796824cdcc3ab205c25f260e15dc6705942d356f114089d4a46f2f3b0b15b52000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e65746400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e".to_owned();

        let easy_proof = "004102e5a40aa610d88964f2fb650511370811440577cd4cd643321f494accd05e10f5183cdb155b98f519e24619fd12a06bb12d9377c03998cb2f06a2b88485b2fc33704f632f518a7b821500cf5c6ee4e3748768af0ca25240f02041845e0d74975d82e6679996244d3bb41c0c36b520eea0ad11918ec44bff83a392d2e4fb7bc5c022275fc4ba242fa4c2503756a004ab262aeda9fac49b92521e2d6a96ab3b9d2fc0c3906da8ba3e87f4b249f81e9dc8cc879019bdffa716a878c9c73ea406fc60597b29f3f503cd9d293017a37cdec80b30f8bd95c6f1a67b7e1afe97a1f7fb4eed3a1e56cbf13c7f034c5373849008df4c6dafd92df0de5421b123a5839800087a8004a1a0e78ca4e0aa50760bc77e8dd00526aed9fa272541f1476ae5476bd520c72694ded1de34a672bdca451e8809d15d98910921e28ee313186e77726a428204672f66b873f35463d78570f126329c0541a5c1af1fb18b429be150fd1de9498d18717b09178a41aa15fd6fa8d7b6737d730fe87ef4ab875ec2459f8b97c604fc6f999d2c1df563e550ba247e5d7318319fcb0c22e39a3bc2d8b782d8fad912652fc151a99af0f4a28311050d77d75a1651d08d7a45676238765bab161c15648c4dd601eab92d169702f5a951b332845e87942ea48b453c177c51fa73e64d67544857f69d342ecd0ebf1e73ed57d7de1f780a9f01ceaa95b586f60ba2a300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001".to_owned();


        let hard_preimage = "3dfca19b9914d78ec0c3d04c486e7baa402e9aaf54ca8c39bab641b0c9829070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c009f240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

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
            configs_ol_miner: self.configs_ol_miner.clone() // 0L change.
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
