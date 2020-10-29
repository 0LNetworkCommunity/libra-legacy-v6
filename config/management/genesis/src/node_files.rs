// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use std::{path::PathBuf, fs};

use libra_config::{config::{ NetworkConfig, SecureBackend, DiscoveryMethod, NodeConfig}, config::OnDiskStorageConfig, config::WaypointConfig, network_id::NetworkId, config::SafetyRulesService};
use libra_crypto::ed25519::Ed25519PublicKey;
use libra_global_constants::OWNER_KEY;
use libra_management::{
    config::ConfigPath, error::Error, secure_backend::ValidatorBackend,
    storage::StorageWrapper as Storage,
};
use libra_temppath::TempPath;
use libra_types::chain_id::ChainId;
use structopt::StructOpt;

use crate::storage_helper::StorageHelper;

/// Prints the public information within a store
#[derive(Debug, StructOpt)]
pub struct Files {
    #[structopt(flatten)]
    config: ConfigPath,
    #[structopt(flatten)]
    backend: ValidatorBackend,
    #[structopt(long)]
    namespace: String,
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
        let chain_id = ChainId::new(1);
        let storage_helper = StorageHelper::get_with_path(output_dir.clone(), &self.namespace);
        let remote = StorageHelper::remote_string(&self.namespace, output_dir.to_str().unwrap());



        // Get node configs template
        let mut config = NodeConfig::default();
        config.set_data_dir(output_dir.clone());

        // Create Genesis File
        let genesis_path = output_dir.join("genesis.blob");
        let genesis = storage_helper
            .genesis_gh(chain_id, &remote, &genesis_path)
            .unwrap();
        config.execution.genesis_file_location = genesis_path;

        // Create and save waypoint
        let waypoint = storage_helper
            .create_waypoint_gh(chain_id, &remote)
            .unwrap();
        storage_helper
            .insert_waypoint(&self.namespace, waypoint)
            .unwrap();

        // Set network configs
        let mut network = NetworkConfig::network_with_id(NetworkId::Validator);
        network.discovery_method = DiscoveryMethod::Onchain;
        config.validator_network = Some(network);

        let mut disk_storage = OnDiskStorageConfig::default();
        disk_storage.set_data_dir(output_dir.clone());
        disk_storage.path = output_dir.clone().join(format!("key_store.{}.json", &self.namespace));
        disk_storage.namespace = Some(self.namespace);
        
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

fn get_ed25519_key(storage: &Storage, key: &'static str) -> Result<Ed25519PublicKey, Error> {
    storage.ed25519_public_from_private(key)
}


        // OK config.consensus.safety_rules.service = SafetyRulesService::Thread;
        // OK config.consensus.safety_rules.backend = self.secure_backend(&local_ns, "safety-rules");
        // config.execution.backend = self.secure_backend(&local_ns, "execution");

        // let backend = self.secure_backend(&local_ns, "safety-rules");
        // config.base.waypoint = WaypointConfig::FromStorage(backend);
        // config.execution.genesis = Some(genesis);
        // config.execution.genesis_file_location = PathBuf::from("");


// fn production(local_ns: &str, path: &Path, storage_helper: &StorageHelper, chain_id ) {
//     // let validator_ns = index.to_string() + OPERATOR_NS;
//     let chain_id = ChainId::new(1);
//     let genesis = storage_helper
//         .genesis(chain_id, path)
//         .unwrap();

//     storage_helper
//         .insert_waypoint(&local_ns, waypoint)
//         .unwrap();

//     let output = storage_helper
//         .verify_genesis(&local_ns, genesis_path.path())
//         .unwrap();
//     assert_eq!(output.split("match").count(), 5, "Failed to verify genesis");

//     let config = NodeConfig::default();
//     config.consensus.safety_rules.service = SafetyRulesService::Thread;
//     config.consensus.safety_rules.backend = self.secure_backend(&local_ns, "safety-rules");
//     config.execution.backend = self.secure_backend(&local_ns, "execution");

//     let backend = self.secure_backend(&local_ns, "safety-rules");
//     config.base.waypoint = WaypointConfig::FromStorage(backend);
//     config.execution.genesis = Some(genesis);
//     config.execution.genesis_file_location = PathBuf::from("");
// }