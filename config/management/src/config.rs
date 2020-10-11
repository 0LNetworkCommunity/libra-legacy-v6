use crate::{error::Error, SingleBackend};
use libra_config::{
    config::{
        DiscoveryMethod, Identity, NetworkConfig, NodeConfig, WaypointConfig,UpstreamConfig, PeerNetworkId
    },
    network_id::NetworkId,
};
use libra_secure_storage::Storage;

use libra_network_address::NetworkAddress;
use structopt::StructOpt;
use log::Level;
use std::{convert::TryInto, fs, path::PathBuf};
use libra_types::{
    transaction::authenticator::AuthenticationKey
};

use super::seeds::Seeds;

#[derive(Debug, StructOpt)]
pub struct Config {
    #[structopt(flatten)]
    backend: SingleBackend,
    #[structopt(long)]
    validator_address: NetworkAddress,
    #[structopt(long)]
    validator_listen_address: NetworkAddress,
    #[structopt(long)]
    fullnode_address: NetworkAddress,
    #[structopt(long)]
    fullnode_listen_address: NetworkAddress,
    #[structopt(long)]
    path: Option<PathBuf>,
}

impl Config {
    pub fn execute(self) -> Result<String, Error> {
        let mut config = NodeConfig::default();

        let local: Box<dyn Storage> = self.backend.backend.clone().try_into().unwrap();
        local
            .available()
            .map_err(|e| Error::LocalStorageUnavailable(e.to_string())).unwrap();


        let key = local
        .get_public_key(libra_global_constants::OPERATOR_KEY).unwrap();

        // NOTE: There's something strange with calling libra-node from a path different from where this storage is located.

        let mut network = NetworkConfig::network_with_id(NetworkId::Validator);
        // println!("network\n{:?}", network);

        network.discovery_method = DiscoveryMethod::Gossip;
        config.validator_network = Some(network);
        config.consensus.round_initial_timeout_ms = 1000;

        config.logger.level = Level::Debug;
        config.upstream = UpstreamConfig::default();

        let path: PathBuf;

        if self.path.is_none() {
            path = PathBuf::from("./");
        } else {
            path = self.path.unwrap();
        }

        let peers = Seeds {
            genesis_path: path.join("genesis.blob")
        };

        let upstream = AuthenticationKey::ed25519(&key.public_key).derived_address();
        config.upstream.primary_networks.push(upstream);


        for (acc, _network_addresses) in peers.get_seed_info().unwrap().seed_peers.iter() {
            if upstream != *acc{
            config.upstream.upstream_peers.insert(PeerNetworkId(upstream,acc.clone()));
            }
        }

        // let address = account_address::from_public_key(&libra_global_constants::OPERATOR_ACCOUNT);
        // config.upstream.primary_networks= vec![address];


        if let Some(network) = config.validator_network.as_mut() {
            network.listen_address = self.validator_listen_address;
            network.advertised_address = self.validator_address;
            network.identity = Identity::from_storage(
                libra_global_constants::VALIDATOR_NETWORK_KEY.into(),
                libra_global_constants::OPERATOR_ACCOUNT.into(),
                self.backend.backend.clone().try_into().unwrap(),
            );
            network.discovery_method = DiscoveryMethod::Gossip;
            //network.network_peers_file = PathBuf::from("./network_peers.toml") ;
            network.seed_peers_file = path.join("seed_peers.toml") ;
        }


        // let fullnode_network = &mut config.full_node_networks[0];
        // fullnode_network.listen_address = self.fullnode_listen_address;
        // fullnode_network.advertised_address = self.fullnode_address;
        // fullnode_network.identity = Identity::from_storage(
        //     libra_global_constants::FULLNODE_NETWORK_KEY.into(),
        //     libra_global_constants::OPERATOR_ACCOUNT.into(),
        //     self.backend.backend.clone().try_into().unwrap(),
        // );


        config.consensus.safety_rules.backend = self.backend.backend.clone().try_into().unwrap();

        // Load waypoint
        config.base.waypoint = WaypointConfig::FromStorage {
            backend: self.backend.backend.clone().try_into().unwrap(),
        };

        // Adding genesis file location
        config.execution.genesis_file_location = path.join("genesis.blob");
        config.storage.prune_window=Some(20_000);

        // TODO: place in path with other files.
        // Save file
        let output_dir = path;

        fs::create_dir_all(&output_dir).expect("Unable to create output directory");
        config
            .save(&output_dir.join("node.configs.toml"))
            .expect("Unable to save node configs");

        Ok(toml::to_string_pretty(&config).unwrap())
    }
}

// fn save_node_config(mut node_config: NodeConfig, output_dir: &PathBuf) {
//     fs::create_dir_all(output_dir).expect("Unable to create output directory");
//     node_config
//         .save(output_dir.join(NODE_CONFIG))
//         .expect("Unable to save node configs");
// }
