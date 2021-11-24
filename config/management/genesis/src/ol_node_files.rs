use std::{fmt::Debug, fs, path::PathBuf};

use diem_config::{
    config::OnDiskStorageConfig,
    config::SafetyRulesService,
    config::{DiscoveryMethod, NetworkConfig, NodeConfig, SecureBackend},
    config::{Identity, UpstreamConfig, WaypointConfig},
    network_id::NetworkId,
};

use crate::{seeds::Seeds, waypoint};
use crate::storage_helper::StorageHelper;
use diem_global_constants::{FULLNODE_NETWORK_KEY, OWNER_ACCOUNT, VALIDATOR_NETWORK_KEY};
use diem_management::{config::ConfigPath, error::Error, secure_backend::ValidatorBackend};
use diem_types::{chain_id::ChainId, waypoint::Waypoint};
use structopt::StructOpt;
/// Prints the public information within a store
#[derive(Debug, StructOpt)]
pub struct Files {
    #[structopt(flatten)]
    config: ConfigPath,
    #[structopt(flatten)]
    backend: ValidatorBackend,
    #[structopt(long)]
    namespace: String,
    #[structopt(long)]
    github_org: Option<String>,
    #[structopt(long)]
    repo: Option<String>,
    #[structopt(long)]
    chain_id: u8,
    /// If specified, compares the internal state to that of a
    /// provided genesis. Note, that a waypont might diverge from
    /// the provided genesis after execution has begun.
    #[structopt(long)]
    data_path: PathBuf,
    #[structopt(long, verbatim_doc_comment)]
    genesis_path: Option<PathBuf>,
    #[structopt(long, verbatim_doc_comment)]
    fullnode_only: bool,
    #[structopt(long, verbatim_doc_comment)]
    waypoint: Option<Waypoint>,
    #[structopt(long, verbatim_doc_comment)]
    layout_path: Option<PathBuf>,
}

impl Files {
    pub fn execute(self) -> Result<NodeConfig, Error> {
        write_node_config_files(
            self.data_path,
            self.chain_id,
            self.github_org,
            self.repo,
            &self.namespace,
            &None,
            &self.fullnode_only,
            self.waypoint,
            &self.layout_path,
        )
    }
}

pub fn write_node_config_files(
    output_dir: PathBuf,
    chain_id: u8,
    github_org: Option<String>,
    repo: Option<String>,
    namespace: &str,
    prebuilt_genesis: &Option<PathBuf>,
    fullnode_only: &bool,
    way_opt: Option<Waypoint>, // TODO: deprecated
    layout_path: &Option<PathBuf>,
) -> Result<NodeConfig, Error> {
    // TODO: Do we need github token path with public repo?
    let github_token_path = output_dir.join("github_token.txt");
    let chain_id = ChainId::new(chain_id);

    let storage_helper = StorageHelper::get_with_path(output_dir.clone());

    let mut genesis_path = output_dir.join("genesis.blob");

    match prebuilt_genesis {
        Some(path) => {
            genesis_path = path.to_owned();
            waypoint::extract_waypoint_from_file(&genesis_path)?
        }
        None => {
          // building a genesis file requires a set_layout path. The default is for genesis to use a local set_layout file. Once a genesis occurs, the canonical chain can store the genesis information to github repo for future verification and creating a genesis blob.
            if *&repo.is_some() && *&github_org.is_some() {
              let remote = format!(
                  "backend=github;repository_owner={github_org};repository={repo};token={path};namespace={ns}",
                  repo=&repo.unwrap(),
                  github_org=&github_org.unwrap(),
                  path=github_token_path.to_str().unwrap(),
                  ns=&namespace
              );
              match layout_path {
                Some(layout_path) => storage_helper
                    .build_genesis_with_layout(chain_id, &remote, &genesis_path, &layout_path)
                    .unwrap(),
                None => {
                  println!("attempting to get a set_layout file from the genesis repo");
                  storage_helper
                    .build_genesis_from_github(chain_id, &remote, &genesis_path)
                    .unwrap()
                },
              }
            } else {
              return Err(Error::ConfigError(format!("ERROR: to build genesis from repo you need to pass --github-org and --repo")))
            }
        }
    };
    
    // storage_helper
    //   .insert_waypoint(&namespace, genesis_waypoint)
    //   .unwrap();

    // Write the genesis waypoint without a namespaced storage.
    let mut disk_storage = OnDiskStorageConfig::default();
    disk_storage.set_data_dir(output_dir.clone());
    disk_storage.path = output_dir.clone().join("key_store.json");
    disk_storage.namespace = Some(namespace.to_owned());

    // Get node configs template
    let mut config = if *fullnode_only {
        let mut c = NodeConfig::default_for_public_full_node();
        c.base.waypoint = WaypointConfig::FromConfig(way_opt.unwrap_or_default());

        c.execution.sign_vote_proposal = false;
        c.execution.genesis_file_location = PathBuf::from("/");
        c
    } else {
        let mut c = NodeConfig::default();

        // Note skip setting namepace for later.
        c.base.waypoint =
            WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));

        // If validator configs set val network configs
        let mut network = NetworkConfig::network_with_id(NetworkId::Validator);

        // NOTE: Using configs as described in cluster tests:
        // testsuite/cluster-test/src/cluster_swarm/configs/validator.yaml
        network.discovery_method = DiscoveryMethod::Onchain;
        network.mutual_authentication = true;
        network.identity = Identity::from_storage(
            VALIDATOR_NETWORK_KEY.to_string(),
            OWNER_ACCOUNT.to_string(),
            SecureBackend::OnDiskStorage(disk_storage.clone()),
        );
        network.network_address_key_backend =
            Some(SecureBackend::OnDiskStorage(disk_storage.clone()));

        c.validator_network = Some(network.clone());

        c.json_rpc.address = "0.0.0.0:8080".parse().unwrap();
        // NOTE: for future reference, seed addresses are not necessary
        // for setting a validator if on-chain discovery is used.

        // Consensus
        c.base.waypoint =
            WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));

        c.execution.backend = SecureBackend::OnDiskStorage(disk_storage.clone());
        c.execution.genesis_file_location = genesis_path.clone();

        c.consensus.safety_rules.service = SafetyRulesService::Thread;
        c.consensus.safety_rules.backend = SecureBackend::OnDiskStorage(disk_storage.clone());

        c
    };

    config.set_data_dir(output_dir.clone());

    ///////// FULL NODE CONFIGS ////////
    let mut fn_network = NetworkConfig::network_with_id(NetworkId::Public);

    fn_network.seed_addrs = Seeds::new(genesis_path.clone())
        .get_network_peers_info()
        .expect("Could not get seed peers");

    fn_network.discovery_method = DiscoveryMethod::Onchain;
    fn_network.listen_address = "/ip4/0.0.0.0/tcp/6179".parse().unwrap();
    fn_network.identity = Identity::from_storage(
        FULLNODE_NETWORK_KEY.to_string(),
        OWNER_ACCOUNT.to_string(),
        SecureBackend::OnDiskStorage(disk_storage.clone()),
    );
    config.full_node_networks = vec![fn_network];

    // NOTE: for future reference, "upstream" is not necessary for validator settings.
    config.upstream = UpstreamConfig {
        networks: vec![NetworkId::Public],
    };

    // Prune window for state snapshots
    config.storage.prune_window = Some(20_000);

    // Write yaml
    let yaml_path = if *fullnode_only {
        output_dir.join("fullnode.node.yaml")
    } else {
        output_dir.join("validator.node.yaml")
    };

    fs::create_dir_all(&output_dir).expect("Unable to create output directory");
    config
        .save(&yaml_path)
        .expect("Unable to save node configs");

    println!(
        "validator configurations initialized, file saved to: {:?}",
        &yaml_path
    );
    Ok(config)
}
 


/// Save node configs to files
pub fn save_node_yaml_files(_output_dir: PathBuf) {

}

// pub fn get_storage_obj(output_dir: PathBuf, namespace: &str) -> Result<OnDiskStorageConfig, Error>{
//       // Write the genesis waypoint without a namespaced storage.
//     let mut disk_storage = OnDiskStorageConfig::default();
//     disk_storage.set_data_dir(output_dir.clone());
//     disk_storage.path = output_dir.clone().join("key_store.json");
//     disk_storage.namespace = Some(namespace.to_owned());
// }

// /// make the validator config settings.
// pub fn make_validator_settings() -> Result<NetworkConfig, Error>{
//         // If validator configs set val network configs
//         let mut network = NetworkConfig::network_with_id(NetworkId::Validator);

//         // NOTE: Using configs as described in cluster tests:
//         // testsuite/cluster-test/src/cluster_swarm/configs/validator.yaml
//         network.discovery_method = DiscoveryMethod::Onchain;
//         network.mutual_authentication = true;
//         network.identity = Identity::from_storage(
//             VALIDATOR_NETWORK_KEY.to_string(),
//             OWNER_ACCOUNT.to_string(),
//             SecureBackend::OnDiskStorage(disk_storage.clone()),
//         );
//         network.network_address_key_backend =
//             Some(SecureBackend::OnDiskStorage(disk_storage.clone()));
// }


// /// make the validator config settings.
// pub fn make_vfn_settings() -> Result<NetworkConfig, Error>{
//   todo!()
//   // create a new identity

// }

// /// make the validator config settings.
// pub fn make_fullnode_settings() -> Result<NetworkConfig, Error>{
// todo!()
// }


pub fn default_for_public_full_node() {
    let path_str= env!("CARGO_MANIFEST_DIR");
    let path = PathBuf::from(path_str)
    .parent()
    .unwrap()
    .parent()
    .unwrap()
    .parent()
    .unwrap()
    .join("ol/util/node_templates/fullnode.node.yaml");

    dbg!(&path);
    // let contents = std::include_str!(&path.to_string());
    
    let contents = fs::read_to_string(&path).expect("could not find mnemonic file");

    let n: NodeConfig = serde_yaml::from_str(&contents).unwrap();

    dbg!(&n);
}

// pub fn default_for_validator() -> Self {
//     let contents = std::include_str!("test_data/validator.yaml");
//     NodeConfig::default_config(contents, "default_for_validator")
// }

// pub fn default_for_validator_full_node() -> Self {
//     let contents = std::include_str!("test_data/validator_full_node.yaml");
//     NodeConfig::default_config(contents, "default_for_validator_full_node")
// }

#[test]
fn test() {
  default_for_public_full_node();
}