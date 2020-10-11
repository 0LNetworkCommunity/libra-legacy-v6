use libra_crypto::{ed25519::Ed25519PublicKey, x25519::PublicKey};
use libra_global_constants::{
    CONSENSUS_KEY, EPOCH, FULLNODE_NETWORK_KEY, LAST_VOTED_ROUND, OPERATOR_KEY, OWNER_KEY,
    PREFERRED_ROUND, VALIDATOR_NETWORK_KEY, WAYPOINT,
};
use libra_secure_storage::{NamespacedStorage, OnDiskStorage, Storage, Value};
use libra_wallet::{Mnemonic, key_factory::{ChildNumber, ExtendedPrivKey, KeyFactory, Seed}};
use std::{
    fs::File,
    path::PathBuf,
};

pub fn key_scheme(mnemonic: String) -> (ExtendedPrivKey, ExtendedPrivKey,ExtendedPrivKey, ExtendedPrivKey) {
    let seed = Seed::new(&Mnemonic::from(&mnemonic).unwrap(), "0L");
    let kf = KeyFactory::new(&seed).unwrap();
    let child_0_owner_operator = kf.private_child(ChildNumber::new(0)).unwrap();
    let child_1_consensus = kf.private_child(ChildNumber::new(1)).unwrap();
    let child_2_val_network = kf.private_child(ChildNumber::new(2)).unwrap();
    let child_3_fullnode_network = kf.private_child(ChildNumber::new(3)).unwrap();
    (child_0_owner_operator, child_1_consensus, child_2_val_network, child_3_fullnode_network)
}

pub struct NodePubKeys{
    pub operator_key: Ed25519PublicKey,
    pub validator_network_key: PublicKey,
    pub consensus_key: Ed25519PublicKey,
    pub fullnode_network_key: PublicKey,
}

impl NodePubKeys {
    pub fn new_from_mnemonic(mut self, mnemonic: String) {
        let (child_0_owner_operator, child_1_consensus, child_2_val_network, child_3_fullnode_network) = key_scheme(mnemonic);
        self.operator_key = child_0_owner_operator.get_public();
        self.consensus_key = child_1_consensus.get_public();
        self.validator_network_key = PublicKey::from_ed25519_public_bytes(&child_2_val_network.get_public().to_bytes()).unwrap();
        self.fullnode_network_key = PublicKey::from_ed25519_public_bytes(&child_3_fullnode_network.get_public().to_bytes()).unwrap();
    }
}
