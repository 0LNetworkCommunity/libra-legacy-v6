//! Utility to generate necesary keys for 0L configuration.

use libra_crypto::{ed25519::Ed25519PublicKey, x25519::PublicKey};
use libra_wallet::{Mnemonic, key_factory::{ChildNumber, ExtendedPrivKey, KeyFactory, Seed}};

/// The set of keys which are used throughout 0L for configuration of validators and miners. Depended on by config/management for genesis.
pub fn key_scheme(mnemonic: String) -> (ExtendedPrivKey, ExtendedPrivKey,ExtendedPrivKey, ExtendedPrivKey) {
    let seed = Seed::new(&Mnemonic::from(&mnemonic).unwrap(), "0L");
    let kf = KeyFactory::new(&seed).unwrap();
    let child_0_owner_operator = kf.private_child(ChildNumber::new(0)).unwrap();
    let child_1_consensus = kf.private_child(ChildNumber::new(1)).unwrap();
    let child_2_val_network = kf.private_child(ChildNumber::new(2)).unwrap();
    let child_3_fullnode_network = kf.private_child(ChildNumber::new(3)).unwrap();
    (child_0_owner_operator, child_1_consensus, child_2_val_network, child_3_fullnode_network)
}

pub struct KeyScheme {
        pub child_0_owner: ExtendedPrivKey,
        pub child_1_operator: ExtendedPrivKey,
        pub child_2_val_network: ExtendedPrivKey,
        pub child_3_fullnode_network: ExtendedPrivKey,
        pub child_4_consensus: ExtendedPrivKey,
        pub child_5_executor: ExtendedPrivKey,
}
pub fn key_scheme_new(mnemonic: String) -> KeyScheme {
    let seed = Seed::new(&Mnemonic::from(&mnemonic).unwrap(), "0L");
    let kf = KeyFactory::new(&seed).unwrap();
    KeyScheme {
        child_0_owner: kf.private_child(ChildNumber::new(0)).unwrap(),
        child_1_operator: kf.private_child(ChildNumber::new(1)).unwrap(),
        child_2_val_network: kf.private_child(ChildNumber::new(2)).unwrap(),
        child_3_fullnode_network: kf.private_child(ChildNumber::new(3)).unwrap(),
        child_4_consensus: kf.private_child(ChildNumber::new(4)).unwrap(),
        child_5_executor: kf.private_child(ChildNumber::new(5)).unwrap(),
    }
}

#[derive(Debug)]
/// Struct with identifying pub keys used when configuring nodes.
pub struct NodePubKeys{
    /// The key which manages the validator node, signs transactions. Same as the owner key.
    pub operator_key: Ed25519PublicKey,
    /// The key which signs votes.
    pub consensus_key: Ed25519PublicKey,
    /// The key which identifies the validator for network connections.
    pub validator_network_key: PublicKey,
    /// The key which identifies a full node for network connections.
    pub fullnode_network_key: PublicKey,
}

impl NodePubKeys {
    /// Generates the necessary pubkeys for validator and full node set up.
    pub fn new_from_mnemonic(mnemonic: String) -> Self {
        let (child_0_owner_operator, child_1_consensus, child_2_val_network, child_3_fullnode_network) = key_scheme(mnemonic);
        Self {
            operator_key: child_0_owner_operator.get_public(),
            consensus_key: child_1_consensus.get_public(),
            validator_network_key: PublicKey::from_ed25519_public_bytes(&child_2_val_network.get_public().to_bytes()).unwrap(),
            fullnode_network_key: PublicKey::from_ed25519_public_bytes(&child_3_fullnode_network.get_public().to_bytes()).unwrap()
        }
    }
    
}

