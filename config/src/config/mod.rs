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

        let easy_preimage = "aa".to_owned();

        let easy_proof = "002fb6ae7221c8593fb21599fdbee8837426761b328f76609295c9175d5f061bb29792236d22366d0d9305040661b54f59cea3f8e143a584f178981549b462bdc96a3ef270dc1457985390a3401c484b721fdd00f0330b894755d34a311c547b73065aec1a71528d0dc350c13fa68aaf34d206a5fa56f7391b889f1226d7aacc3624eca7f27d523db4f2f18e4ca0bd4cd91b4133cce16b40245d9d393a0c32013f91c5d2bfaca7e5e4c4f71ea90bdc9047657e02e7a429b3f4988b3a7f0789a6c4e0b60af26139dba0c5a83eecc785dbdde0012e47ef3af7fe60e366b8e87ac437da111c8ffb57f400980513b47db04c47787380ea564ffaf1653aa5889e5b31340022cfdd5956cf2fc9130ea4e45a700a5fbd990aae8a4643b22508b6d0b6b80186b5eea2c656296ad2d2043867bd93d48a284b90c2792aeeb25f6a7f0dacac617e7660074e18109e6675480ebc6340f4b01d74d8e5943b9bc8f9acdb3d8ebef5f593858913ebbc2f0d4b1fc76dacca4b032bb8d97e018a614e667bbbb07da891d23028b60275bc2c715e975b347c2e72e5753282959973f34742a43393d76b025b6444e4cabf4272eceae3d94a19ae1f24edf725e8892eb45f34e8a224a5ee56effa8f4b5a3a3bf810579cba99f0e954ce8459afe963bbb2c2578bd5de48e6df56a29ef03dda9e03e19c08fed8b467065afd38720f634c646698a1841c4a21037700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001".to_owned();


        let hard_preimage = "c82573d01fe624ef83619299430eacedc82573d01fe624ef83619299430eaced000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c009f240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374".to_owned();

        let hard_proof =  "0000f47a5f2e7d3002e1cd7882de930dc1e1786f9c1e3b42e59057ef37e1240fc3a737e2851bef8a6ef6917b593267332cd0e9024e00b5b81a3f75bd4fd6f478182cdd5d176b4a5cb2ae62fa7cc648ba68e649cc102e983aa9f1a074bed364c1abe8b6cbf751a69191c4962d6267eb1c2426495eb33c91803fafa24ac197972a574145a5fb95829778b82ba5a4ad5f2ae13a9032344e3aea32651a067eb9ac23ccd20bb33c64e55a89c53b2d592a60b6dd0f7541c50592e39eee3272c025e2aefa63b78f44f67d4f135ae4a1560a8be08805c37697635d0e9c9aca7d783ede23d519d2e0563994d750ead872052de093315333121dbb0748d3a398898d147ff4e400009a69db65304b4ab6af39f6e8b74a50ed637339c45661d1484045355faab60fedc602a58d619dc6f6dafdbdcc65627ef5f9e38e32f86f07f54c54f475c6c6d4c85331f8f23bd1d8343055978c1a76cf23e66044d9ebe80dee5e7b7474654851d32a4209ab722f02d537c421ce6a563b40279274cc125eff8a3700e0a3de010150718076ce266e9efda8f3ddcf0fa6effa688a90bc8b219e269db6ef448368c8d6970e5769f0f29f0d46541fb1af3101c560701ca41b2a8b1772d3c0509b127a7226b8d159d126bcd1d6f70f9d0f26dab38ced1bb24e1f5d6fbbaaefcf94a782cb2c88877601797786396b18156301788ccdf449ac2d46664b87e4d33a6806ef004d0efe9be1546c6328148cfc6dd2feb9f78c90215b992f6d961834e3880cd2048baeb9c5686f20eb8554db70763d4b0d9846512856e60dc9c10000b19941e4e6331be3cbb60d3e98395263f3e8c8b2f836ec38600f4a527dc0c473d0a3e9084847b9f70424b20ec511e6fed2d7c7f70e9a366267da2da982c9b4ad4442367c9acec887b7629648d13334a4c1500048c5b2e5a4746ecb34a189675058332818ed530af2e5471d600bc0d3dcc4d4b74256807a02d94632e8b841b0329352d72c71440ef0b8380693004431fcb685c513a8f9fd136f0d8d4cb283efa7f0b2cde93468bf539210e5780e5bf295180fbd1c5d240dcf6a0149f8135d708ff11ad5e721ffc8c73e92e571d33d6387981873a4b0cf44d4d117871807a55da595279b8139200ab6d283b8603444608d2071115e5b62c8619e123ef2ae1967716c39711e56009615e8b3d52a95f49fc2cb9eb6aaa15175bf7af5abc9fc7f447428f36a0d36bbb751e4fa964884d5f7fa260937124f58dfe33c0c2cc2f8f466483f68b33d9dbae137e82efd9e24bd19af91ebd1f2dfa64fb4bff7f589511af94f78bc18071c2f583c7a0e1d78b7f9e7ee36af0f7d74f19bc18386552ebf6cd08b2eb358a355019aed2135a79376e6c07364ca9c3f8f1e73f7f69e9a21358835a2c959a87af639a80ab05e14fb3afceb3065ea6efdca8c8a3a2a764e3e71c720d3da0d4fbc98b1".to_owned();

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
