// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0
// Modified 0L

use crate::keys::KeyPair;
use libra_crypto::{ed25519::Ed25519PrivateKey, PrivateKey, Uniform};
use libra_temppath::TempPath;
use libra_types::{
    on_chain_config::VMPublishingOption, transaction::authenticator::AuthenticationKey,
};
use rand::rngs::StdRng;
use serde::{Deserialize, Serialize};
use std::path::Path;
// use libra_wallet::Mnemonic;

use libra_wallet::WalletLibrary;

type AccountKeyPair = KeyPair<Ed25519PrivateKey>;
type ConsensusKeyPair = KeyPair<Ed25519PrivateKey>;

#[derive(Debug, Default, Deserialize, Serialize)]
pub struct TestConfig {
    pub auth_key: Option<AuthenticationKey>,
    #[serde(rename = "operator_private_key")]
    pub operator_keypair: Option<AccountKeyPair>,
    #[serde(rename = "consensus_private_key")]
    pub consensus_keypair: Option<ConsensusKeyPair>,
    // Used to initialize storage defaults in safety rules
    pub initialize_storage: bool,
    // Used only to prevent a potentially temporary data_dir from being deleted. This should
    // eventually be moved to be owned by something outside the config.
    #[serde(skip)]
    temp_dir: Option<TempPath>,

    pub publishing_option: Option<VMPublishingOption>,
}

#[cfg(any(test, feature = "fuzzing"))]
impl Clone for TestConfig {
    fn clone(&self) -> Self {
        Self {
            auth_key: self.auth_key,
            operator_keypair: self.operator_keypair.clone(),
            consensus_keypair: self.consensus_keypair.clone(),
            initialize_storage: self.initialize_storage,
            temp_dir: None,
            publishing_option: self.publishing_option.clone(),
        }
    }
}

impl PartialEq for TestConfig {
    fn eq(&self, other: &Self) -> bool {
        self.operator_keypair == other.operator_keypair
            && self.auth_key == other.auth_key
            && self.consensus_keypair == other.consensus_keypair
            && self.initialize_storage == other.initialize_storage
    }
}

impl TestConfig {
    pub fn open_module() -> Self {
        Self {
            auth_key: None,
            operator_keypair: None,
            consensus_keypair: None,
            initialize_storage: false,
            temp_dir: None,
            publishing_option: Some(VMPublishingOption::Open),
        }
    }

    pub fn new_with_temp_dir() -> Self {
        let temp_dir = TempPath::new();
        temp_dir.create_as_dir().expect("error creating tempdir");
        Self {
            auth_key: None,
            operator_keypair: None,
            consensus_keypair: None,
            initialize_storage: false,
            temp_dir: Some(temp_dir),
            publishing_option: None,
        }
    }

    pub fn random_account_key(&mut self, _rng: &mut StdRng) {
        // 0L NOTE: This is for testing only, including libra-swarm.
        // let mnemonic = Mnemonic::mnemonic(&privkey.to_bytes()).expect("Unable to create Mnemonic for privkey");
        // let privkey = Ed25519PrivateKey::generate(rng);

        let mut wallet = WalletLibrary::new();
        let (auth_key, _child_number) = wallet.new_address().expect("Could not generate address");
        self.auth_key = Some(auth_key);

        let mnemonic_string = wallet.mnemonic(); //wallet.mnemonic()
        let privkey = wallet.get_privkey_at_child(0).export_priv_key();

        // Add asserts to test this
        // let seed = Seed::new(&Mnemonic::from(&mnemonic_string).unwrap(), "OL");
        // let kf = KeyFactory::new(&seed).unwrap();
        // let child_0 = kf.private_child(ChildNumber::new(0)).unwrap();
        // let privkey = child_0.export_priv_key();


        println!("=========\n\
        Auth_Key\n{:?}",
        &auth_key.to_string());

        println!("Mnemonic:\n\
        {:?}\n\
        =========", &mnemonic_string);


        // let layout_text = "\
        //     operators = [\"alice\", \"bob\"]\n\
        //     owners = [\"carol\"]\n\
        //     association = [\"dave\"]\n\
        // ";

        // "[workspace]\
        // home = \".\"\
        // \
        // [profile]\
        // auth_key = \"3dfca19b9914d78ec0c3d04c486e7baa402e9aaf54ca8c39bab641b0c9829070\"\
        // statement = \"test\"\
        // \
        // [chain_info]\
        // chain_id = \"experimental\"\
        // block_dir= \"./blocks/\"\
        // node =\"http://192.241.147.210:8080\"\
        // base_waypoint=\"0:84d016400cc028105965a4778507e451dee3c35fbbd4353bfcb564a7511e5316\"\
        // "

        
        // // let mut config_path = PathBuf::from("./test_miner.toml");
        // // config_path.push(format!("test_miner.toml");
        // //println!("{:?}", &latest_block_path);
        // let miner_config_file = "./miner.toml";
        // let mut file = fs::File::create(&miner_config_file).unwrap();
        // file.write(&toml.as_bytes())
        //     .expect("Could not write block");

        self.operator_keypair = Some(AccountKeyPair::load(privkey));
    }



    pub fn random_consensus_key(&mut self, rng: &mut StdRng) {
        let privkey = Ed25519PrivateKey::generate(rng);
        self.consensus_keypair = Some(ConsensusKeyPair::load(privkey));
    }

    pub fn temp_dir(&self) -> Option<&Path> {
        self.temp_dir.as_ref().map(|temp_dir| temp_dir.path())
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use rand::{rngs::StdRng, SeedableRng};

    #[test]
    fn verify_test_config_equality_using_keys() {
        // Create default test config without keys
        let mut test_config = TestConfig::new_with_temp_dir();
        assert_eq!(test_config.operator_keypair, None);
        assert_eq!(test_config.consensus_keypair, None);

        // Clone the config and verify equality
        let mut clone_test_config = test_config.clone();
        assert_eq!(clone_test_config, test_config);

        // Generate keys for original test config
        let mut rng = StdRng::from_seed([0u8; 32]);
        test_config.random_account_key(&mut rng);
        test_config.random_consensus_key(&mut rng);

        // Verify that configs differ
        assert_ne!(clone_test_config, test_config);

        // Copy keys across configs
        clone_test_config.operator_keypair = test_config.operator_keypair.clone();
        clone_test_config.consensus_keypair = test_config.consensus_keypair.clone();
        clone_test_config.auth_key = test_config.auth_key;

        // Verify both configs are identical
        assert_eq!(clone_test_config, test_config);
    }
}
