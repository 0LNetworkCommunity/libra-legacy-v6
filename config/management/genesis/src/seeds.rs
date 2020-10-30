use libra_crypto::x25519::PublicKey;
use libra_management::error::Error;
use executor::db_bootstrapper;
use libra_config::config::{PersistableConfig, SeedAddresses};
use libra_temppath::TempPath;
use libra_types::{account_config, account_state::AccountState, PeerId, on_chain_config::ValidatorSet, waypoint::Waypoint};
use structopt::StructOpt;

use libra_network_address::NetworkAddress;
use libra_vm::LibraVM;
use libradb::LibraDB;
use std::{
    convert::TryFrom,
    fs::File,
    io::Read,
    path::{Path, PathBuf},
};

use storage_interface::DbReaderWriter;

use crate::verify::compute_genesis;


/// Prints the public information within a store
#[derive(Debug, StructOpt)]
pub struct Seeds {
    /// Path to genesis file to extract seed nodes
    #[structopt(long, verbatim_doc_comment)]
    pub genesis_path: PathBuf,
}

impl Seeds {
    pub fn new(genesis_path: PathBuf) -> Self {
      Self {
        genesis_path,
      }
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

        let info = validator_set.payload();
        dbg!(info);
        let mut seed_addr = SeedAddresses::default();
        // let vec_peers: Vec<NetworkAddress> = Vec::new();

        for info in info.iter() {
          //TODO: skip own address?
            // vec_peers.push
            dbg!(info);
            let seed_pubkey = info.config().consensus_public_key;
            //NOTE: This usually expects a x25519 key
            let x25519 = PublicKey::from_ed25519_public_bytes(&seed_pubkey.to_bytes()).expect("Seed peers could not generate x25519 identitykey from ed25519 key provided");
            let peer_id = PeerId::from_identity_public_key(x25519);

            let addr: NetworkAddress = info.config().validator_network_addresses.into();
            
            // .append_prod_protos(seed_pubkey, HANDSHAKE_VERSION);
            // vec_peers.push(seed_addr);
            seed_addr.insert(peer_id, vec!(addr));
        }

        Ok(seed_addr)
    }
  }


    //   let seed_pubkey = libra_crypto::PrivateKey::public_key(&seed_config.identity_key());
    // let seed_addr = seed_base_addr.append_prod_protos(seed_pubkey, HANDSHAKE_VERSION);

    // let mut seed_addrs = SeedAddresses::default();
    // seed_addrs.insert(seed_config.peer_id(), vec![seed_addr]);
    // seed_addrs