use std::{path::PathBuf, fs};

use libra_config::{config::{ NetworkConfig, SecureBackend, DiscoveryMethod, NodeConfig}, config::OnDiskStorageConfig, config::SafetyRulesService, config::{Identity, WaypointConfig}, network_id::NetworkId};
use libra_global_constants::{OWNER_ACCOUNT, VALIDATOR_NETWORK_KEY};
use libra_management::{
    config::ConfigPath, error::Error, secure_backend::ValidatorBackend,
};
use libra_types::chain_id::ChainId;
use structopt::StructOpt;
use crate::{storage_helper::StorageHelper};

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
        let output_dir = self.data_path;
        let chain_id = ChainId::new(self.chain_id);
        let storage_helper = StorageHelper::get_with_path(output_dir.clone());
        let remote = format!("backend=github;repository_owner=OLSF;repository={repo};token={path}/github_token.txt;namespace={ns}", repo=&self.repo, path=output_dir.to_str().unwrap(), ns=&self.namespace); 

        // Get node configs template
        let mut config = NodeConfig::default();
        config.set_data_dir(output_dir.clone());
        // Create Genesis File
        let genesis_path = output_dir.join("genesis.blob");
        storage_helper
            .genesis_gh(chain_id, &remote, &genesis_path)
            .unwrap();
        config.execution.genesis_file_location = genesis_path.clone();

        // Create and save waypoint
        let waypoint = storage_helper
            .create_waypoint_gh(chain_id, &remote)
            .unwrap();
        storage_helper
            .insert_waypoint(&self.namespace, waypoint)
            .unwrap();
        let mut disk_storage = OnDiskStorageConfig::default();
        disk_storage.set_data_dir(output_dir.clone());
        disk_storage.path = output_dir.clone().join("key_store.json");
        disk_storage.namespace = Some(self.namespace);

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
        
        // TODO: Set a fullnode network key for the fullnodes which can connect to this validator.
        // config.full_node_networks = vec!(network);

        // NOTE: for future reference, "upstream" is not necessary for validator settings.
        // config.upstream = UpstreamConfig { networks: vec!(NetworkId::Validator)};
        
        // NOTE: for future reference, seed addresses are not necessary for setting a validator if on-chain discovery is used.
        // network.seed_addrs = Seeds::new(genesis_path.clone()).get_network_peers_info().expect("Could not get seed peers");
        
        // Consensus
        config.base.waypoint = WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));
        
        config.execution.backend = SecureBackend::OnDiskStorage(disk_storage.clone());

        config.consensus.safety_rules.service = SafetyRulesService::Thread;
        config.consensus.safety_rules.backend = SecureBackend::OnDiskStorage(disk_storage.clone());

        // Misc
        // config.storage.prune_window=Some(20_000);

        // Write yaml
        fs::create_dir_all(&output_dir).expect("Unable to create output directory");
        config
            .save(&output_dir.join("node.yaml"))
            .expect("Unable to save node configs");

        Ok("node.yaml created".to_string())
    }
}
