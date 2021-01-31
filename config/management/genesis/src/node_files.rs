use std::{path::PathBuf, fs};

use libra_config::{config::{ NetworkConfig, SecureBackend, DiscoveryMethod, NodeConfig}, config::OnDiskStorageConfig, config::SafetyRulesService, config::{Identity, WaypointConfig}, network_id::NetworkId};
use libra_global_constants::{OWNER_ACCOUNT, VALIDATOR_NETWORK_KEY};
use libra_management::{config::ConfigPath, error::Error, secure_backend::{SharedBackend, ValidatorBackend}};
use libra_temppath::TempPath;
use libra_types::{chain_id::ChainId, waypoint::Waypoint};
use libra_vm::LibraVM;
use libradb::LibraDB;
use storage_interface::DbReaderWriter;
use structopt::StructOpt;
use crate::{storage_helper::StorageHelper};
use executor::db_bootstrapper;

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
        create_files(self.data_path, self.chain_id, self.repo, self.namespace)
    }
}

pub fn create_files(data_path: PathBuf, chain_id: u8, repo: String, namespace: String) -> Result<String, Error> {
    let output_dir = data_path;
    let github_token_path = data_path.join("github_token.txt");
    let chain_id = ChainId::new(chain_id);
    let storage_helper = StorageHelper::get_with_path(output_dir.clone());
    
    let remote = format!(
        "backend=github;repository_owner=OLSF;repository={repo};token={path};namespace={ns}",
        repo=&repo,
        path=github_token_path.to_str().unwrap(),
        ns=&namespace
    ); 

    // Get node configs template
    let mut config = NodeConfig::default();
    config.set_data_dir(output_dir.clone());

    /////////////////////////////////////////
    // Create Genesis File
    let genesis_path = output_dir.join("genesis.blob");
    // storage_helper
    //     .genesis_gh(chain_id, &remote, &genesis_path)
    //     .unwrap();
    // config.execution.genesis_file_location = genesis_path.clone();
    // ////////////////////////////////

    // Create and save waypoint
    let waypoint = storage_helper
        .create_waypoint_gh(chain_id, &remote, &genesis_path)
        .unwrap();

    storage_helper
        .insert_waypoint(&namespace, waypoint)
        .unwrap();
    let mut disk_storage = OnDiskStorageConfig::default();
    disk_storage.set_data_dir(output_dir.clone());
    disk_storage.path = output_dir.clone().join("key_store.json");
    disk_storage.namespace = Some(namespace);

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
    config.storage.prune_window=Some(20_000);

    // Write yaml
    fs::create_dir_all(&output_dir).expect("Unable to create output directory");
    config
        .save(&output_dir.join("node.yaml"))
        .expect("Unable to save node configs");

    Ok("node.yaml created".to_string())
}

pub fn build_genesis_from_repo(
    output_dir: PathBuf,
    chain_id: u8,
    repo_owner: String,
    repo_name: String,
    namespace: String,
) -> PathBuf {
    let chain_id = ChainId::new(chain_id);
    let storage_helper = StorageHelper::get_with_path(output_dir.clone());

    let remote = format!(
        "backend=github;repository_owner={owner};repository={repo};token={path}/github_token.txt;namespace={ns}", 
        owner=&repo_owner,
        repo=&repo_name,
        path=output_dir.to_str().unwrap(),
        ns=&namespace
    );

    /////////////////////////////////////////
    // Create Genesis File
    let genesis_path = output_dir.join("genesis.blob");
    storage_helper
        .genesis_gh(chain_id, &remote, &genesis_path)
        .unwrap();
    genesis_path
}

pub fn build_genesis(
    config: ConfigPath,
    chain_id: u8,
    shared_backend: SharedBackend,
    path: PathBuf,
) -> Result<Waypoint, Error> {
    let chain_id = ChainId::new(chain_id);

    let genesis_helper = crate::genesis::Genesis {
        config: config,
        chain_id: Some(chain_id),
        backend: shared_backend,
        path: Some(path),
    };

    let genesis = genesis_helper.execute()?;

    let path = TempPath::new();
    let libradb =
        LibraDB::open(&path, false, None).map_err(|e| Error::UnexpectedError(e.to_string()))?;
    let db_rw = DbReaderWriter::new(libradb);

    db_bootstrapper::generate_waypoint::<LibraVM>(&db_rw, &genesis)
        .map_err(|e| Error::UnexpectedError(e.to_string()))
}
