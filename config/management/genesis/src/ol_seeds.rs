use crate::verify::compute_genesis;
use diem_crypto::x25519::PublicKey;
use diem_management::error::Error;
use diem_temppath::TempPath;
use diem_types::{
    account_config, account_address::from_identity_public_key,
    account_state::AccountState, PeerId,
    on_chain_config::ValidatorSet, network_address::NetworkAddress,
};
use std::{convert::TryFrom, collections::HashMap, path::PathBuf, fs};
use structopt::StructOpt;

pub type SeedAddresses = HashMap<PeerId, Vec<NetworkAddress>>; 

// NOTE: Deprecated for use on validator config. Kept here for reference.
/// Prints the public information within a store
#[derive(Debug, StructOpt)]
pub struct Seeds {
    /// Path to genesis file to extract seed nodes
    #[structopt(long, verbatim_doc_comment)]
    pub genesis_path: PathBuf,
}

impl Seeds {
    pub fn execute(self) -> Result<String, Error> {
        let peers = &self.get_network_peers_info()?;
        dbg!(peers);
        Ok("ok".to_string())
    }

    pub fn new(genesis_path: PathBuf) -> Self {
      Self { genesis_path }
    }

    pub fn read_from_file(seed_peers_path: PathBuf) -> Result<SeedAddresses, Error>  {
        let file_string = fs::read_to_string(seed_peers_path)
            .map_err(|e| Error::ConfigError(e.to_string()))?;
        let yaml: SeedAddresses = serde_yaml::from_str(&file_string)
            .map_err(|e| Error::ConfigError(e.to_string()))?;
        Ok(yaml)
    }

    pub fn get_network_peers_info(&self)->Result<SeedAddresses, Error> {
        let db_path = TempPath::new();

        let (db_rw, _expected_waypoint) = compute_genesis(&self.genesis_path, db_path.path())?;

        let blob = db_rw
            .reader
            .get_latest_account_state(account_config::validator_set_address())
            .map_err(|e| {
                Error::UnexpectedError(format!("ValidatorSet Account issue {}", e.to_string()))
            })
            .unwrap()
            .unwrap();

        let account_state = AccountState::try_from(&blob)
            .map_err(|e| Error::UnexpectedError(format!("Failed to parse blob: {}", e)))
            .unwrap();

        let validator_set: ValidatorSet = account_state
            .get_validator_set()
            .map_err(|e| Error::UnexpectedError(format!("ValidatorSet issue {}", e.to_string())))?
            .ok_or_else(|| Error::UnexpectedError("ValidatorSet does not exist".into()))?;

        let mut seed_addr = SeedAddresses::default();
        let info = validator_set.payload();
        for info in info.iter() {
            let seed_pubkey = info.config().consensus_public_key.clone();
            //NOTE: This usually expects a x25519 key
            let x25519 = PublicKey::from_ed25519_public_bytes(
                &seed_pubkey.to_bytes()
            ).expect("Seed peers could not generate x25519 identitykey from ed25519 key provided");
            let peer_id = from_identity_public_key(x25519);

            // use validator address, not the operator consensus key.
            // let peer_id = info.account_address().to_owned();
            let addr_vec = info.config().fullnode_network_addresses()
                .expect("Get the Fullnode network address");
            seed_addr.insert(peer_id, addr_vec);
        }

        Ok(seed_addr)
    }
}