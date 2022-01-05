use std::{fmt::Debug, fs, net::Ipv4Addr, path::PathBuf, process::exit};

use crate::{storage_helper::StorageHelper, seeds::SeedAddresses};
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
use diem_crypto::x25519::PublicKey;
use diem_global_constants::{
    DEFAULT_PUB_PORT, DEFAULT_VFN_PORT, FULLNODE_NETWORK_KEY, OWNER_ACCOUNT,
    VALIDATOR_NETWORK_KEY,
};
use diem_management::{config::ConfigPath, error::Error, secure_backend::ValidatorBackend};
use diem_secure_storage::{CryptoStorage, KVStorage};
use diem_types::{account_address::AccountAddress, chain_id::ChainId, waypoint::Waypoint};
use ol_types::account::ValConfigs;
use serde::{Deserialize, Serialize};
use structopt::StructOpt;
use diem_crypto::x25519::PrivateKey;

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
        onboard_helper_all_files(
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

pub fn onboard_helper_all_files(
    output_dir: PathBuf,
    chain_id: u8,
    github_org: Option<String>,
    repo: Option<String>,
    namespace: &str,
    prebuilt_genesis: &Option<PathBuf>,
    _fullnode_only: &bool,
    seed_peers_path: Option<PathBuf>,
    layout_path: &Option<PathBuf>,
    val_ip_address: Option<Ipv4Addr>,
) -> Result<NodeConfig, anyhow::Error> {
    // TODO: Do we need github token path with public repo?
    let chain_id = ChainId::new(chain_id);

    let storage_helper = StorageHelper::get_with_path(output_dir.clone());
    dbg!("get_with_path success");

    let (_genesis_path, genesis_waypoint) = make_genesis_file(
        &output_dir,
        prebuilt_genesis,
        &repo,
        &github_org,
        layout_path,
        storage_helper,
        chain_id,
        namespace,
    )?;

    dbg!(&genesis_waypoint);


    update_genesis_waypoint_in_key_store(&output_dir, namespace, genesis_waypoint.clone());
    dbg!("update_genesis_waypoint_in_key_store success");

    // fullnodes need seed peers, try to extract from the genesis file as a starting place.
    let seeds: Option<SeedAddresses> = if let Some(p) = seed_peers_path {
      let file_string = fs::read_to_string(&p)?;
      let yaml: SeedAddresses = serde_yaml::from_str(&file_string)?;
      Some(yaml)
    } else { None };

    dbg!(&seeds);

    let vfn_ip_address = val_ip_address.clone();
    // This next step depends on genesis waypoint existing in key_store.
    make_all_profiles_yaml(
      output_dir,
      val_ip_address.expect("missing an ip address for validator"),
      vfn_ip_address, 
      seeds,
      namespace, 
      genesis_waypoint
    )
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
    val_ip_address: Ipv4Addr,
    vfn_ip_address: Option<Ipv4Addr>,
    seed_addr: Option<SeedAddresses>,
    namespace: &str,
    genesis_waypoint: Waypoint,
    // _fullnode_only: bool,
) -> Result<NodeConfig, anyhow::Error> {


    let config = make_val_file(output_dir.clone(), vfn_ip_address, namespace)?;
    dbg!(&config);
    make_vfn_file(output_dir.clone(), val_ip_address, genesis_waypoint, namespace)?;
    dbg!("make_vfn_file success");
    make_fullnode_file(output_dir.clone(), seed_addr, genesis_waypoint)?;
    dbg!("make_fullnode_file success");

    Ok(config)
    
}

// helper to write a new validator.node.yaml file.
pub fn make_val_file(
    output_dir: PathBuf,
    // val_ip_address: Ipv4Addr,
    _vfn_ip_address: Option<Ipv4Addr>,
    namespace: &str,
) -> Result<NodeConfig, anyhow::Error> {
  // TODO: The validator's connection to VFN should be restricted to the vfn_ip_address
    let mut val = make_validator_cfg(output_dir.clone(), namespace)?;
    write_yaml(output_dir.clone(), &mut val, NodeType::Validator)?;
    Ok(val)
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
    seed_addr: Option<SeedAddresses>,
    gen_wp: Waypoint,
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
          dbg!(&path);
            // TODO: insert waypoint
            let gen_wp_path = path.parent().unwrap().join("genesis_waypoint.txt");
            let wp: Waypoint =
                fs::read_to_string(&gen_wp_path)?
                    .parse().map_err(|_| anyhow::anyhow!("cannot parse genesis_waypoint.txt"))?;
            dbg!(&wp);
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
                        .build_genesis_with_layout(chain_id, &remote, &genesis_path, &layout_path)?,
                    None => {
                        println!("attempting to get a set_layout file from the genesis repo");
                        storage_helper
                            .build_genesis_from_github(chain_id, &remote, &genesis_path)?
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
    // c.execution.genesis_file_location = output_dir.clone().join("genesis.blob");
    
    // prune window exists to prevent state snapshots from taking up too much space.
    c.storage.prune_window = Some(100_000);
    
    // Public fullnodes have JSON RPC enabled to the public (0.0.0.0), so that the validator does not need to do so.
    c.json_rpc.address = "0.0.0.0:8080".parse()?;

    // Public fullnodes only connect to one network. Public fullnodes network.
    let mut pub_network = NetworkConfig::network_with_id(NetworkId::Public);
    pub_network.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_PUB_PORT).parse()?;

    if let Some(seeds) = seed_addr {
      pub_network.seed_addrs  = seeds;
    }

    c.full_node_networks = vec![pub_network];

    Ok(c)
}

fn make_validator_cfg(output_dir: PathBuf, namespace: &str) -> Result<NodeConfig, anyhow::Error> {
    // TODO: make the validator node have mutual authentication with VFN.
    // for that it will need to get the Peer object of the VFN after the identity has been created
    // by default the VFN identity is random.
    let mut disk_storage = OnDiskStorageConfig::default();
    disk_storage.set_data_dir(output_dir.clone());
    disk_storage.path = output_dir.clone().join("key_store.json");
    disk_storage.namespace = Some(namespace.to_owned());

    let mut c = NodeConfig::default();

    c.set_data_dir(output_dir.clone());
    // Note skip setting namepace for later.
    c.base.waypoint =
        WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));
    c.base.role = RoleType::Validator;
    // If validator configs set val network configs
    let mut network = NetworkConfig::network_with_id(NetworkId::Validator);

    let network_id = Identity::from_storage(
        VALIDATOR_NETWORK_KEY.to_string(),
        OWNER_ACCOUNT.to_string(),
        SecureBackend::OnDiskStorage(disk_storage.clone()),
    );
    // NOTE: Using configs as described in cluster tests:
    // testsuite/cluster-test/src/cluster_swarm/configs/validator.yaml
    network.discovery_method = DiscoveryMethod::Onchain;
    network.mutual_authentication = true;
    network.identity = network_id.clone(); // will also use for VFN.

    network.network_address_key_backend = Some(SecureBackend::OnDiskStorage(disk_storage.clone()));

    c.validator_network = Some(network.clone());

    // Consensus
    c.base.waypoint =
        WaypointConfig::FromStorage(SecureBackend::OnDiskStorage(disk_storage.clone()));

    c.execution.backend = SecureBackend::OnDiskStorage(disk_storage.clone());
    // c.execution.genesis_file_location = output_dir.clone().join("genesis.blob");

    c.consensus.safety_rules.service = SafetyRulesService::Thread;
    c.consensus.safety_rules.backend = SecureBackend::OnDiskStorage(disk_storage.clone());

    c.storage.prune_window = Some(100_000);

    //////////////// CREATE CONFIGS FOR CONNECTING TO VFN PRIVATE NETWORK ////////////////
    // this is the only fullnode network a validator should connect to, so to be isolated from public.

    // TODO: The validator's connection to VFN should be restricted to the vfn_ip_address
    let mut vfn_net = NetworkConfig::network_with_id(NetworkId::Private("vfn".to_string()));
    vfn_net.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_VFN_PORT).parse()?;
    
    // This ID is how the Validator node identifies themselves on their private VFN network.
    // same ID as being used in the validator network.
    vfn_net.identity = network_id;
    c.full_node_networks = vec![vfn_net.to_owned()];

    // pick the order of the networks to connect to if the Validator network is not reachable.
    // TODO: Does this work for when the validator is not in the validator set? This has not worked int he past.
    c.upstream.networks = vec![NetworkId::Private("vfn".to_owned()), NetworkId::Public];

    // NOTE: Validator does not have public JSON RPC enabled. Only for localhost queries
    // this is set with the NodeConfig defaults.

    Ok(c)
}

/// make the fullnode NodeConfig
pub fn make_vfn_cfg(
    output_dir: PathBuf,
    waypoint: Waypoint,
    val_ip_address: Ipv4Addr,
    namespace: &str,
) -> Result<NodeConfig, anyhow::Error> {
    let mut c = NodeConfig::default();

    let storage_helper = get_default_keystore_helper(output_dir.clone());
    // Set base properties
    c.set_data_dir(output_dir.clone());
    c.base.waypoint = WaypointConfig::FromConfig(waypoint);
    c.base.role = RoleType::FullNode;
    // c.execution.genesis_file_location = output_dir.clone().join("genesis.blob");

    let storage = storage_helper.storage(namespace.to_string());
    c.storage.prune_window = Some(100_000);

    

    //////////////// CREATE CONFIGS FOR CONNECTING TO VFN PRIVATE NETWORK ////////////////

    // Private Fullnode Network named "vfn" - but could be any name the validator and vfn agreed on
    let mut vfn_network = NetworkConfig::network_with_id(NetworkId::Private("vfn".to_string()));
    //////////////// IDENTITY OF NODE  ////////////////
    // the VFN announces itself as the owner address, but uses FULLNODE private key to authenticate.
    // make the fullnode discoverable by the account address of the validator owner.
    let owner_address_as_fn_id = storage.get(OWNER_ACCOUNT)?.value;
    
    // TODO: determine if we want deterministic identity. Seems to not work with VFN, for now allowing the network configs to generate random ID for VFN.

    // NOTE: WE ARE CHOSING TO HAVE THE FULLNODE NETWORK PRIVATE KEY UNECRPYTED IN THE CONFIG FILE
    // this is preferable to the VFN also storing the key_store.json on the host
    // which is equally insecure, and contains many more keys.


    // let fullnode_private_key = storage.export_private_key(FULLNODE_NETWORK_KEY)?;

    // let p = PrivateKey::from_ed25519_private_bytes(&fullnode_private_key.to_bytes())?;
    // let id_of_vfn_node = Identity::from_config(p, owner_address_as_fn_id);

    // A VFN has two fullnode networks it participates in.
    // 1. A private network with the Validator.
    // 2. the fullnode network. The fullnode network cannot exist unless the VFN briges the validators to the public.

    // vfn_network.identity = id_of_vfn_node.clone();


    // set the Validator as the Seed peer for the VFN network
    // need to get their ID and IP address

    let val_net_private_key = storage.export_private_key(VALIDATOR_NETWORK_KEY)?;

    let p = PrivateKey::from_ed25519_private_bytes(&val_net_private_key.to_bytes())?;
    
    let seeds = make_vfn_peer_set(owner_address_as_fn_id, p.public_key(), val_ip_address)?;

    // The seed for the VFN is the validator's ID on the private network.
    vfn_network.seeds = seeds;

    // TODO: This should be restricted to receiving connections from a known peer.
    vfn_network.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_VFN_PORT).parse()?;

    //////////////// CREATE CONFIGS FOR CONNECTING TO PUBLIC FULLNODES ////////////////

    // Public fullnode network template
    let mut pub_network = NetworkConfig::network_with_id(NetworkId::Public);
    
    // TODO: decide if we want deterministic addresses for public network.
    // using the same ID on both private vfn network as well as public network.
    // pub_network.identity = id_of_vfn_node;

    // this port accepts connections from unknown peers.
    pub_network.listen_address = format!("/ip4/0.0.0.0/tcp/{}", DEFAULT_PUB_PORT).parse()?;

    // NOTE: VFNs do not serve JSON RPC Requests.

    c.full_node_networks = vec![vfn_network, pub_network];

    // pick the order of the networks to connect to if the VFN network is not reachable.
    c.upstream.networks = vec![NetworkId::Public];

    Ok(c)
}

fn make_vfn_peer_set(
    validator_account: AccountAddress,
    val_vfn_net_pubkey: PublicKey,
    ip_address: Ipv4Addr,
) -> Result<PeerSet, Error> {
    // create the vfn network info.
    let val_peer_data = make_validator_network_protocol(ip_address, val_vfn_net_pubkey)?;
    // The seed address for the VFN can only be the Validator's address.
    let mut seeds = PeerSet::default();
    seeds.insert(validator_account, val_peer_data);
    Ok(seeds)
}

pub fn make_validator_network_protocol(
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
