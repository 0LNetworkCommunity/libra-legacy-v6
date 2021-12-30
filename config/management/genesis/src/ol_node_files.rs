use std::{fmt::Debug, fs, net::Ipv4Addr, path::PathBuf, process::exit};

use crate::{storage_helper::StorageHelper, seeds::{SeedAddresses, Seeds}};
use anyhow::bail;
use diem_config::{
    config::OnDiskStorageConfig,
    config::SafetyRulesService,
    config::{
        DiscoveryMethod, NetworkConfig, NodeConfig, Peer, PeerRole, PeerSet, RoleType,
        SecureBackend,
    },
    config::{Identity, WaypointConfig},
    network_id::NetworkId,
};
use diem_crypto::{ed25519::Ed25519PublicKey, x25519::PublicKey};
use diem_global_constants::{
    DEFAULT_PUB_PORT, DEFAULT_VFN_PORT, FULLNODE_NETWORK_KEY, GENESIS_WAYPOINT, OWNER_ACCOUNT,
    VALIDATOR_NETWORK_KEY,
};
use diem_management::{config::ConfigPath, error::Error, secure_backend::ValidatorBackend};
use diem_secure_storage::{CryptoStorage, KVStorage};
use diem_types::{account_address::AccountAddress, chain_id::ChainId, waypoint::Waypoint};
use ol_types::account::ValConfigs;
use serde::{Deserialize, Serialize};
use structopt::StructOpt;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum NodeType {
    Validator,
    ValidatorFullNode,
    PublicFullNode,
}

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
    #[structopt(long, verbatim_doc_comment)]
    val_ip_address: Option<Ipv4Addr>,
    #[structopt(long, verbatim_doc_comment)]
    seed_peers_path: Option<PathBuf>,
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
            self.seed_peers_path,
            &self.layout_path,
            self.val_ip_address,
        )
        .map_err(|e| {
            Error::ConfigError(format!(
                "Could not write node config files, message: {}",
                e.to_string()
            ))
        })
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
    seed_peers_path: Option<PathBuf>,
    layout_path: &Option<PathBuf>,
    val_ip_address: Option<Ipv4Addr>,
) -> Result<NodeConfig, anyhow::Error> {
    // TODO: Do we need github token path with public repo?
    let chain_id = ChainId::new(chain_id);

    let storage_helper = StorageHelper::get_with_path(output_dir.clone());

    let (genesis_path, genesis_waypoint) = make_genesis_file(
        &output_dir,
        prebuilt_genesis,
        &repo,
        &github_org,
        layout_path,
        storage_helper,
        chain_id,
        namespace,
    )?;

    update_genesis_waypoint_in_key_store(&output_dir, namespace, genesis_waypoint);

    // fullnodes need seed peers, try to extract from the genesis file as a starting place.
    let seeds: Option<SeedAddresses> = if let Some(p) = seed_peers_path {
      let file_string = fs::read_to_string(&p)?;
      let yaml: SeedAddresses = serde_yaml::from_str(&file_string)?;
      Some(yaml)
    } else { None };

    let vfn_ip_address = val_ip_address.clone();
    // This next step depends on genesis waypoint existing in key_store.
    make_all_profiles_yaml(output_dir, val_ip_address, vfn_ip_address, seeds, namespace, *fullnode_only)
}

fn get_default_keystore_helper(output_dir: PathBuf) -> StorageHelper {
    StorageHelper::get_with_path(output_dir)
}

fn update_genesis_waypoint_in_key_store(
    output_dir: &PathBuf,
    namespace: &str,
    genesis_waypoint: Waypoint,
) {
    let storage_helper = StorageHelper::get_with_path(output_dir.clone());
    // for genesis cases, need to insert the waypoint in the key_store.json
    storage_helper
        .insert_waypoint(namespace, genesis_waypoint)
        .unwrap();
}

/// Make all the node configurations needed
pub fn make_all_profiles_yaml(
    output_dir: PathBuf,
    val_ip_address: Option<Ipv4Addr>,
    vfn_ip_address: Option<Ipv4Addr>,
    seed_addr: Option<SeedAddresses>,
    namespace: &str,
    fullnode_only: bool,
) -> Result<NodeConfig, anyhow::Error> {
    // get the key_store storage interface for disk.
    let storage_helper = get_default_keystore_helper(output_dir.clone());
    let s = storage_helper.storage(namespace.to_owned());
    let gw = s.get::<Waypoint>(GENESIS_WAYPOINT)?.value;
    // Get node configs template
    let config = if fullnode_only {
        let mut n = make_fullnode_cfg(output_dir.clone(), seed_addr, gw)?;
        write_yaml(output_dir.clone(), &mut n, NodeType::PublicFullNode)?;
        n
    } else {
        // fullnode configs, only used for rescuing a validator node that's out of validator set.
        let mut fullnode = make_fullnode_cfg(output_dir.clone(), seed_addr, gw)?;
        write_yaml(output_dir.clone(), &mut fullnode, NodeType::PublicFullNode)?;

        // vfn configs
        if let Some(ip_address) = val_ip_address {
            let mut vfn = make_vfn_cfg(output_dir.clone(), gw, ip_address, namespace)?;
            write_yaml(output_dir.clone(), &mut vfn, NodeType::ValidatorFullNode)?;
        } else {
            bail!("VFN settings requires a val_ip_address");
        }

        // validator configs

        let mut n = make_validator_cfg(output_dir.clone(), namespace)?;
        write_yaml(output_dir.clone(), &mut n, NodeType::Validator)?;
        n
    };

    Ok(config)
    
}

// helper to write a new validator.node.yaml file.
pub fn make_val_file(
    output_dir: PathBuf,
    val_ip_address: Option<Ipv4Addr>,
    vfn_ip_address: Option<Ipv4Addr>,
    namespace: &str,
) -> Result<(), anyhow::Error> {
    let mut val = make_validator_cfg(output_dir.clone(), namespace)?;
    write_yaml(output_dir.clone(), &mut val, NodeType::Validator)
}

// helper to write a new validator.node.yaml file.
pub fn make_vfn_file(
    output_dir: PathBuf,
    val_ip_address: Ipv4Addr,
    gen_wp: Waypoint,
    namespace: &str,
) -> Result<(), anyhow::Error> {
    let mut vfn = make_vfn_cfg(output_dir.clone(), gen_wp, val_ip_address, namespace)?;
    write_yaml(output_dir.clone(), &mut vfn, NodeType::ValidatorFullNode)
}

// helper to write a new validator.node.yaml file.
pub fn make_fullnode_file(
    output_dir: PathBuf,
    val_ip_address: Ipv4Addr,
    seed_addr: Option<SeedAddresses>,
    gen_wp: Waypoint,
    namespace: &str,
) -> Result<(), anyhow::Error> {
    let mut n = make_fullnode_cfg(output_dir.clone(), seed_addr, gen_wp)?;
    write_yaml(output_dir.clone(), &mut n, NodeType::PublicFullNode)
}


fn write_yaml(
    output_dir: PathBuf,
    config: &mut NodeConfig,
    role: NodeType,
) -> Result<(), anyhow::Error> {
    let filename = match role {
        NodeType::Validator => "validator.node.yaml",
        NodeType::ValidatorFullNode => "vfn.node.yaml",
        NodeType::PublicFullNode => "fullnode.node.yaml",
    };

    let yaml_path = output_dir.join(filename);
    fs::create_dir_all(&output_dir)?;
    config.save(&yaml_path)?;

    println!(
        "validator configurations initialized, file saved to: {:?}",
        &yaml_path
    );
    Ok(())
}

// we need to both write the genesis file and return the waypoint so we can set it in the key_store.json
fn make_genesis_file(
    output_dir: &PathBuf,
    prebuilt_genesis: &Option<PathBuf>,
    repo: &Option<String>,
    github_org: &Option<String>,
    layout_path: &Option<PathBuf>,
    storage_helper: StorageHelper,
    chain_id: ChainId,
    namespace: &str,
) -> Result<(PathBuf, Waypoint), anyhow::Error> {
    let genesis_path = output_dir.join("genesis.blob");
    match prebuilt_genesis {
        Some(path) => {
            // TODO: insert waypoint
            let wp: Waypoint =
                fs::read_to_string(&path.parent().unwrap().join("genesis_waypoint.txt"))?
                    .parse()?;
            Ok((path.to_owned(), wp))
        }
        None => {
            if repo.is_some() && github_org.is_some() {
                let remote = format!(
                    "backend=github;repository_owner={github_org};repository={repo};token={path};namespace={ns}",
                    repo = repo.as_ref().unwrap(),
                    github_org = github_org.as_ref().unwrap(),
                    path = output_dir.join("github_token.txt").to_str().unwrap(),
                    ns = &namespace
                );
                // building a genesis file requires a set_layout path. The default is for genesis to use a local set_layout file. Once a genesis occurs, the canonical chain can store the genesis information to github repo for future verification and creating a genesis blob.
                let genesis_waypoint = match layout_path {
                    Some(layout_path) => storage_helper
                        .build_genesis_with_layout(chain_id, &remote, &genesis_path, &layout_path)
                        .unwrap(),
                    None => {
                        println!("attempting to get a set_layout file from the genesis repo");
                        storage_helper
                            .build_genesis_from_github(chain_id, &remote, &genesis_path)
                            .unwrap()
                    }
                };
                Ok((genesis_path, genesis_waypoint))
            } else {
                println!("Expected either a prebuilt genesis file, or github repo and org to build a new genesis, exiting.");
                exit(1);
            }
        }
    }
}

fn make_validator_cfg(output_dir: PathBuf, namespace: &str) -> Result<NodeConfig, anyhow::Error> {
    // TODO: make the validator node have mutual authentication with VFN.
    // for that it will need to get the Peer object of the VFN after the identity has been created
    // by default the VFN identity is random.
    let mut disk_storage = OnDiskStorageConfig::default();
    disk_storage.set_data_dir(output_dir.clone());
    disk_storage.path = output_dir.clone().join("key_store.json");
    disk_storage.namespace = Some(namespace.to_owned());

    // let mut c = default_for_validator()?;
    let mut c = NodeConfig::default();

    c.set_data_dir(output_dir.clone());
    // Note skip setting namepace for later.
    c.base.waypoint =
        WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));
    c.base.role = RoleType::Validator;
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
    network.network_address_key_backend = Some(SecureBackend::OnDiskStorage(disk_storage.clone()));

    c.validator_network = Some(network.clone());

    // Consensus
    c.base.waypoint =
        WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));

    c.execution.backend = SecureBackend::OnDiskStorage(disk_storage.clone());
    c.execution.genesis_file_location = output_dir.clone().join("genesis.blob");

    c.consensus.safety_rules.service = SafetyRulesService::Thread;
    c.consensus.safety_rules.backend = SecureBackend::OnDiskStorage(disk_storage.clone());

    c.storage.prune_window = Some(20_000);

    // VFN Settings of the FullNode
    // the validator only participates in 1 fullnode network, it's own VFN.

    let id_for_vfn_network = Identity::from_storage(
        FULLNODE_NETWORK_KEY.to_string(),
        OWNER_ACCOUNT.to_string(),
        SecureBackend::OnDiskStorage(disk_storage.clone()),
    );

    let mut vfn_net = NetworkConfig::network_with_id(NetworkId::Private("vfn".to_string()));
    vfn_net.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_VFN_PORT).parse()?;
    vfn_net.identity = id_for_vfn_network;
    c.full_node_networks = vec![vfn_net.to_owned()];

    // NOTE: Validator does not have public JSON RPC enabled. Only for localhost queries
    // this is set with the NodeConfig defaults.

    Ok(c)
}



/// make the fullnode NodeConfig
pub fn make_fullnode_cfg(
    output_dir: PathBuf,
    seed_addr: Option<SeedAddresses>,
    waypoint: Waypoint,
) -> Result<NodeConfig, anyhow::Error> {
    let mut c = default_for_public_fullnode()?;
    c.set_data_dir(output_dir.clone());
    c.base.waypoint = WaypointConfig::FromConfig(waypoint);
    c.base.role = RoleType::FullNode;
    c.execution.genesis_file_location = output_dir.clone().join("genesis.blob");

    // Public fullnodes only connect to one network. Public fullnode.
    let mut pub_network = NetworkConfig::network_with_id(NetworkId::Public);
    pub_network.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_PUB_PORT).parse()?;

    // Public fullnodes have JSON RPC enabled to the public (0.0.0.0), so that the validator does not need to do so.
    c.json_rpc.address = "0.0.0.0:8080".parse()?;

    // prune window exists to prevent state snapshots from taking up too much space.
    c.storage.prune_window = Some(100_000);

    if let Some(seeds) = seed_addr {
      pub_network.seed_addrs  = seeds;
    }

    c.full_node_networks = vec![pub_network];

    Ok(c)
}

/// make the fullnode NodeConfig
pub fn make_vfn_cfg(
    output_dir: PathBuf,
    waypoint: Waypoint,
    // validator_addr: PeerId,
    ip_address: Ipv4Addr,
    namespace: &str,
    // fn_net_pubkey: PublicKey,
) -> Result<NodeConfig, anyhow::Error> {
    // let mut c = default_for_vfn()?;
    let mut c = NodeConfig::default();

    let storage_helper = get_default_keystore_helper(output_dir.clone());
    // Set base properties
    c.set_data_dir(output_dir.clone());
    c.base.waypoint = WaypointConfig::FromConfig(waypoint);
    c.base.role = RoleType::FullNode;
    c.execution.genesis_file_location = output_dir.clone().join("genesis.blob");

    let storage = storage_helper.storage(namespace.to_string());

    // A VFN has two fullnode networks it participates in.
    // 1. A private network with the Validator.
    // 2. the fullnode network. The fullnode network cannot exist unless the VFN briges the validators to the public.
    // Private Fullnode Network named "vfn" - but could be any name the validator and vfn agreed on
    let mut vfn_network = NetworkConfig::network_with_id(NetworkId::Private("vfn".to_string()));

    // set the Validator as the Seed peer for the VFN network
    // TODO: The validator address, Is it a namespace or is it used for authentication?
    // let validator_addr: AccountAddress = storage.get::<String>(OWNER_ACCOUNT)?.value.parse()?;
    let val_vfn_net_pubkey = storage.get_public_key(FULLNODE_NETWORK_KEY)?.public_key;
    dbg!(&val_vfn_net_pubkey);
    let seeds = make_vfn_peer_set(val_vfn_net_pubkey, ip_address)?;

    // update the template (instead of creating from default)
    // let net = &mut c.full_node_networks[0];
    vfn_network.seeds = seeds;
    vfn_network.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_VFN_PORT).parse()?;

    // Public fullnode network
    let mut pub_network = NetworkConfig::network_with_id(NetworkId::Public);
    pub_network.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_PUB_PORT).parse()?;

    // VFNs have JSON RPC enabled to the public (0.0.0.0), so that the validator does not need to do so.
    c.json_rpc.address = "0.0.0.0:8080".parse()?;

    c.full_node_networks = vec![vfn_network, pub_network];

    c.storage.prune_window = Some(20_000);

    Ok(c)
}

fn make_vfn_peer_set(
    val_vfn_net_pubkey: Ed25519PublicKey,
    ip_address: Ipv4Addr,
) -> Result<PeerSet, Error> {
    let bytes = val_vfn_net_pubkey.to_bytes();
    let validator_vfn_net_addr = AccountAddress::from_identity_public_key(bytes.into());

    // let fn_net_pubkey = validators_id_for_vfn_network.
    // create the vfn network info.
    let val_peer_data = validator_upstream_peer_data(ip_address, bytes.into())?;
    // The seed address for the VFN can only be the Validator's address.
    let mut seeds = PeerSet::default();
    seeds.insert(validator_vfn_net_addr, val_peer_data);
    Ok(seeds)
}

pub fn validator_upstream_peer_data(
    ip_address: Ipv4Addr,
    pubkey: PublicKey,
) -> Result<Peer, Error> {
    let role = PeerRole::Validator;
    let val_addr = ValConfigs::make_vfn_addr(&ip_address.to_string(), pubkey);
    let p = Peer::from_addrs(role, vec![val_addr]);
    Ok(p)
}



pub fn default_for_public_fullnode() -> Result<NodeConfig, anyhow::Error> {
    let path_str = env!("CARGO_MANIFEST_DIR");
    let path = PathBuf::from(path_str)
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("ol/util/node_templates/fullnode.node.yaml");

    let contents = fs::read_to_string(&path)?;
    let n: NodeConfig = serde_yaml::from_str(&contents)?;

    Ok(n)
}

pub fn test_default_for_vfn() -> Result<NodeConfig, anyhow::Error> {
    let path_str = env!("CARGO_MANIFEST_DIR");
    let path = PathBuf::from(path_str)
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("ol/util/node_templates/vfn.node.yaml");

    let contents = fs::read_to_string(&path)?;
    let n: NodeConfig = serde_yaml::from_str(&contents)?;

    Ok(n)
}

pub fn test_default_for_validator() -> Result<NodeConfig, anyhow::Error> {
    let path_str = env!("CARGO_MANIFEST_DIR");
    let path = PathBuf::from(path_str)
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("ol/util/node_templates/validator.node.yaml");

    let contents = fs::read_to_string(&path)?;
    let n: NodeConfig = serde_yaml::from_str(&contents)?;

    Ok(n)
}

pub fn test_default_for_public_full_node() {
    let path_str = env!("CARGO_MANIFEST_DIR");
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
