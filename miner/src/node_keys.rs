//! Key derivation for 0L.

use libra_crypto::{ed25519::Ed25519PublicKey, x25519::PublicKey};
use libra_wallet::{Mnemonic, key_factory::{ChildNumber, ExtendedPrivKey, KeyFactory, Seed}};

/// The key derivation used throughout 0L for configuration of validators and miners. Depended on by config/management for genesis.
// #[derive(Debug)]
pub struct KeyScheme {
        pub child_0_owner: ExtendedPrivKey,
        pub child_1_operator: ExtendedPrivKey,
        pub child_2_val_network: ExtendedPrivKey,
        pub child_3_fullnode_network: ExtendedPrivKey,
        pub child_4_consensus: ExtendedPrivKey,
        pub child_5_executor: ExtendedPrivKey,
}

impl KeyScheme {
    /// Generates the necessary pubkeys for validator and full node set up.
    pub fn new_from_mnemonic(mnemonic: String) -> Self {
        let seed = Seed::new(&Mnemonic::from(&mnemonic).unwrap(), "0L");
        let kf = KeyFactory::new(&seed).unwrap();
        Self {
            child_0_owner: kf.private_child(ChildNumber::new(0)).unwrap(),
            child_1_operator: kf.private_child(ChildNumber::new(1)).unwrap(),
            child_2_val_network: kf.private_child(ChildNumber::new(2)).unwrap(),
            child_3_fullnode_network: kf.private_child(ChildNumber::new(3)).unwrap(),
            child_4_consensus: kf.private_child(ChildNumber::new(4)).unwrap(),
            child_5_executor: kf.private_child(ChildNumber::new(5)).unwrap(),
        }
    }
    
}
