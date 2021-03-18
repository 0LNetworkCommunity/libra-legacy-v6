use std::{path::PathBuf, fs};

use libra_config::{config::{ 
        NetworkConfig,
        SecureBackend,
        DiscoveryMethod,
        NodeConfig
    }, config::OnDiskStorageConfig, config::SafetyRulesService, config::{Identity, UpstreamConfig, WaypointConfig}, network_id::NetworkId};

use libra_global_constants::{OWNER_ACCOUNT, VALIDATOR_NETWORK_KEY};
use libra_management::{
    config::ConfigPath,
    error::Error,
    secure_backend::ValidatorBackend
};
use libra_types::{chain_id::ChainId, waypoint::Waypoint};
use structopt::StructOpt;
use crate::storage_helper::StorageHelper;
use crate::seeds::Seeds;
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
    github_org: String,
    #[structopt(long)]
    repo: String,
    #[structopt(long)]
    chain_id: u8,
    /// If specified, compares the internal state to that of a
    /// provided genesis. Note, that a waypont might diverge from
    /// the provided genesis after execution has begun.
    #[structopt(long)]
    data_path: PathBuf,
    #[structopt(long, verbatim_doc_comment)]
    genesis_path: Option<PathBuf>,
}

impl Files {
    pub fn execute(self) -> Result<String, Error> {
        create_files(self.data_path, self.chain_id, &self.github_org, &self.repo, &self.namespace, &true)
    }
}

pub fn create_files(
    output_dir: PathBuf,
    chain_id: u8,
    github_org: &str,
    repo: &str,
    namespace: &str,
    rebuild_genesis: &bool,
) -> Result<String, Error> {

    let github_token_path = output_dir.join("github_token.txt");
    let chain_id = ChainId::new(chain_id);
    let storage_helper = StorageHelper::get_with_path(output_dir.clone());
    
    let remote = format!(
        "backend=github;repository_owner={github_org};repository={repo};token={path};namespace={ns}",
        repo=&repo,
        github_org=&github_org,
        path=github_token_path.to_str().unwrap(),
        ns=&namespace
    ); 

    // Get node configs template
    let mut config = NodeConfig::default();
    config.set_data_dir(output_dir.clone());


    let genesis_path = output_dir.join("genesis.blob");
    let waypoint: Waypoint;
    if *rebuild_genesis {
        // Create genesis blob from repo and saves waypoint
        waypoint = storage_helper
        .build_genesis_from_github(chain_id, &remote, &genesis_path)
        .unwrap();
    } else {
        // assumes genesis.blob and genesis_waypoint is in output_dir, only inserts to key_store.json
        // read genesis_waypoint file.
        waypoint = fs::read_to_string( output_dir.join("genesis_waypoint"))
        .expect("could not read waypoint file.")
        .trim()
        .parse()
        .expect("could not parse waypoint string");
    }


    storage_helper
        .insert_waypoint(&namespace, waypoint)
        .unwrap();
    
    let mut disk_storage = OnDiskStorageConfig::default();
    disk_storage.set_data_dir(output_dir.clone());
    disk_storage.path = output_dir.clone().join("key_store.json");
    disk_storage.namespace = Some(namespace.to_owned());

    // Set network configs
    let mut network = NetworkConfig::network_with_id(NetworkId::Validator);
    
    // NOTE: Using configs as described in cluster tests: testsuite/cluster-test/src/cluster_swarm/configs/validator.yaml
    network.discovery_method = DiscoveryMethod::Onchain;
    network.mutual_authentication = true;
    network.identity = Identity::from_storage(
        VALIDATOR_NETWORK_KEY.to_string(),
        OWNER_ACCOUNT.to_string(),
        SecureBackend::OnDiskStorage(disk_storage.clone()),
    );
    network.network_address_key_backend = Some(SecureBackend::OnDiskStorage(disk_storage.clone()));


    config.validator_network = Some(network.clone());
    
    ///////// FULL NODE CONFIGS ////////
    let mut fn_network = NetworkConfig::network_with_id(NetworkId::Public);
    
    fn_network.seed_addrs = Seeds::new(genesis_path.clone()).get_network_peers_info().expect("Could not get seed peers");

    fn_network.discovery_method = DiscoveryMethod::Onchain;
    fn_network.listen_address = "/ip4/0.0.0.0/tcp/6179".parse().unwrap();

    config.full_node_networks = vec!(fn_network);

    // NOTE: for future reference, "upstream" is not necessary for validator settings.
    config.upstream = UpstreamConfig { networks: vec!(NetworkId::Public)};
    
    // NOTE: for future reference, seed addresses are not necessary for setting a validator if on-chain discovery is used.
    
    // Consensus
    config.base.waypoint = WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));
    
    config.execution.backend = SecureBackend::OnDiskStorage(disk_storage.clone());
    config.execution.genesis_file_location = genesis_path.clone();

    config.consensus.safety_rules.service = SafetyRulesService::Thread;
    config.consensus.safety_rules.backend = SecureBackend::OnDiskStorage(disk_storage.clone());

    // Misc
    config.storage.prune_window=Some(20_000);

    // Write yaml
    let yaml_path = output_dir.join("validator.node.yaml");
    fs::create_dir_all(&output_dir).expect("Unable to create output directory");
    config
        .save(&yaml_path)
        .expect("Unable to save node configs");

    Ok(yaml_path.to_str().unwrap().to_string())
}