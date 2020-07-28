use structopt::StructOpt;
use crate::{error::Error, SingleBackend};
use libra_temppath::TempPath;
use libra_types::{
    account_address::AccountAddress, account_config, account_state::AccountState,
    on_chain_config::ValidatorSet, validator_config::ValidatorConfig, waypoint::Waypoint,
    PeerId
};
use executor::db_bootstrapper;
use libra_config::config::PersistableConfig;

use libra_network_address::NetworkAddress;
use std::collections::HashMap;
use std::{
    convert::{TryFrom, TryInto},
    fmt::Write,
    fs::File,
    io::Read,
    path::{Path, PathBuf},
    str::FromStr,
    sync::Arc,
};
use libra_vm::LibraVM;
use libradb::LibraDB;

use storage_interface::{DbReader, DbReaderWriter};



/// Prints the public information within a store
#[derive(Debug, StructOpt)]
pub struct Seeds {
    /// Path to genesis file to extract seed nodes
    #[structopt(long, verbatim_doc_comment)]
    genesis_path: PathBuf,
}

pub type SeedPeersConfig = HashMap<PeerId, Vec<NetworkAddress>>;

impl Seeds {
    pub fn execute(self) -> Result<String, Error> {

        let db_path = TempPath::new();

        let (db_rw, expected_waypoint) = compute_genesis(&self.genesis_path, db_path.path())?;

        let blob = db_rw.reader
        .get_latest_account_state(account_config::validator_set_address())
        .map_err(|e| {
            Error::UnexpectedError(format!("ValidatorSet Account issue {}", e.to_string()))
        }).unwrap().unwrap();

        let account_state = AccountState::try_from(&blob)
        .map_err(|e| Error::UnexpectedError(format!("Failed to parse blob: {}", e))).unwrap();

        let validator_set: ValidatorSet = account_state
        .get_validator_set()
        .map_err(|e| Error::UnexpectedError(format!("ValidatorSet issue {}", e.to_string())))?
        .ok_or_else(|| Error::UnexpectedError("ValidatorSet does not exist".into()))?;

        let info = validator_set
        .payload();

        let mut seeds:SeedPeersConfig = HashMap::new();

        for info in info.iter() {
            seeds.insert(info.account_address().clone(),vec![NetworkAddress::try_from(&info.config().full_node_network_address).unwrap()]);
        }

        seeds.save_config("seed_peers.toml")
        .expect("Unable to save seed peers config");

        Ok("Wrote seed_peers.toml".to_string())

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