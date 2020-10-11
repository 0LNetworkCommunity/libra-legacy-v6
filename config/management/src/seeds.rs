use crate::error::Error;
use executor::db_bootstrapper;
use libra_config::config::PersistableConfig;
use libra_temppath::TempPath;
use libra_types::{
    account_config,
    account_state::AccountState,
    on_chain_config::ValidatorSet,
    waypoint::Waypoint,
};
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

use libra_config::config::{SeedPeersConfig, NetworkPeersConfig, NetworkPeerInfo};

/// Prints the public information within a store
#[derive(Debug, StructOpt)]
pub struct Seeds {
    /// Path to genesis file to extract seed nodes
    #[structopt(long, verbatim_doc_comment)]
    pub genesis_path: PathBuf,
}

impl Seeds {
    pub fn execute(self) -> Result<String, Error> {

        let seeds = self.get_seed_info();
        let peers = self.get_network_peers_info();
        seeds.unwrap()
            .save_config("seed_peers.toml")
            .expect("Unable to save seed peers config");

        peers.unwrap()
        .save_config("network_peers.toml")
        .expect("Unable to save network peers config");

        Ok("Wrote seed_peers.toml".to_string())
    }

    pub fn get_network_peers_info(&self)->Result<NetworkPeersConfig, Error> {
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

        let mut netpeers = NetworkPeersConfig::default();

        for info in info.iter() {
            netpeers.peers.insert(
                info.account_address().clone(),
                NetworkPeerInfo{identity_public_key: info.network_identity_public_key()},
            );
        }

        Ok(netpeers)
    }

    pub fn get_seed_info(&self) -> Result<SeedPeersConfig, Error>  {
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

        let mut seeds = SeedPeersConfig::default();

        for info in info.iter() {
            seeds.seed_peers.insert(
                info.account_address().clone(),
                vec![NetworkAddress::try_from(&info.config().validator_network_address).unwrap(),NetworkAddress::try_from(&info.config().validator_network_address).unwrap()],
            );
        }

        Ok(seeds)
    }
}



/// Compute the ledger given a genesis writeset transaction and return access to that ledger and
/// the waypoint for that state.
fn compute_genesis(
    genesis_path: &PathBuf,
    db_path: &Path,
) -> Result<(DbReaderWriter, Waypoint), Error> {
    let libradb =
        LibraDB::open(db_path, false, None).map_err(|e| Error::UnexpectedError(e.to_string()))?;
    let db_rw = DbReaderWriter::new(libradb);

    let mut file = File::open(genesis_path)
        .map_err(|e| Error::UnexpectedError(format!("Unable to open genesis file: {}", e)))?;
    let mut buffer = vec![];
    file.read_to_end(&mut buffer)
        .map_err(|e| Error::UnexpectedError(format!("Unable to read genesis: {}", e)))?;
    let genesis = lcs::from_bytes(&buffer)
        .map_err(|e| Error::UnexpectedError(format!("Unable to parse genesis: {}", e)))?;

    let waypoint = db_bootstrapper::bootstrap_db_if_empty::<LibraVM>(&db_rw, &genesis)
        .map_err(|e| Error::UnexpectedError(e.to_string()))?
        .ok_or_else(|| Error::UnexpectedError("Unable to generate a waypoint".to_string()))?;

    Ok((db_rw, waypoint))
}
