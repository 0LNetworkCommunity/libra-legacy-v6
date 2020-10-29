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
    /// PeerId/AccountAddress of the namespace
    #[structopt(long, verbatim_doc_comment)]
    pub peer_id: PeerId
}

impl Seeds {
    pub fn new(genesis_path: PathBuf, peer_id: PeerId) -> Self {
      Self {
        genesis_path,
        peer_id
      }
    }

    // pub fn execute(self) -> Result<String, Error> {

    //     // let seeds = self.get_seed_info();
    //     let peers = self.get_network_peers_info();
    //     seeds.unwrap()
    //         .save_config("seed_peers.toml")
    //         .expect("Unable to save seed peers config");

    //     peers.unwrap()
    //     .save_config("network_peers.toml")
    //     .expect("Unable to save network peers config");

    //     Ok("Wrote seed_peers.toml".to_string())
    // }

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
        let vec_peers: Vec<NetworkAddress> = Vec::new();

        for info in info.iter() {
          //TODO: skip own address?
          vec_peers.push(info.config().validator_network_addresses().unwrap());
        }
        seed_addr.insert(self.peer_id, vec_peers);

        Ok(seed_addr)
    }
  }