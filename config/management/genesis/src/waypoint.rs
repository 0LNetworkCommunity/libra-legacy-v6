// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use std::{fs::File, io::Read, path::PathBuf};

use diem_config::config::RocksdbConfig;
use diem_management::{config::ConfigPath, error::Error, secure_backend::SharedBackend};
use diem_temppath::TempPath;
use diem_types::{chain_id::ChainId, transaction::Transaction, waypoint::Waypoint};
use diem_vm::DiemVM;
use diemdb::DiemDB;
use executor::db_bootstrapper;
use storage_interface::DbReaderWriter;
use structopt::StructOpt;

/// Produces a waypoint from Genesis from the shared storage. It then computes the Waypoint and
/// optionally inserts it into another storage, typically the validator storage.
#[derive(Debug, StructOpt)]
pub struct CreateWaypoint {
    #[structopt(flatten)]
    config: ConfigPath,
    #[structopt(long, required_unless("config"))]
    chain_id: Option<ChainId>,
    #[structopt(flatten)]
    shared_backend: SharedBackend,
    //////// 0L ////////
    #[structopt(long)]
    genesis_path: Option<std::path::PathBuf>,
    #[structopt(long)]
    layout_path: Option<std::path::PathBuf>,
}

impl CreateWaypoint {
    pub fn execute(self) -> Result<Waypoint, Error> {
        let genesis_helper = crate::genesis::Genesis {
            config: self.config,
            chain_id: self.chain_id,
            backend: self.shared_backend,
            path: self.genesis_path,       //////// 0L ////////
            layout_path: self.layout_path, //////// 0L ////////
        };

        let genesis = genesis_helper.execute()?;

        let path = TempPath::new();
        let diemdb = DiemDB::open(&path, false, None, RocksdbConfig::default())
            .map_err(|e| Error::UnexpectedError(e.to_string()))?;
        let db_rw = DbReaderWriter::new(diemdb);

        db_bootstrapper::generate_waypoint::<DiemVM>(&db_rw, &genesis)
            .map_err(|e| Error::UnexpectedError(e.to_string()))
    }
}

//////// 0L ////////

pub fn extract_waypoint_from_file(genesis_path: &PathBuf) -> Result<Waypoint, Error> {
    let mut file = File::open(genesis_path)
        .map_err(|_| Error::UnexpectedError("cannot open genesis.blob file".to_string()))?;

    let mut buffer = vec![];
    file.read_to_end(&mut buffer)
        .map_err(|_| Error::UnexpectedError("cannot open genesis.blob file".to_string()))?;

    let gen_tx: Transaction = bcs::from_bytes(&buffer)
        .map_err(|_| Error::UnexpectedError("cannot open genesis.blob file".to_string()))?;

    let path = TempPath::new();
    let libradb = DiemDB::open(&path, false, None, RocksdbConfig::default())
        .map_err(|e| Error::UnexpectedError(e.to_string()))?;
    let db_rw = DbReaderWriter::new(libradb);

    db_bootstrapper::generate_waypoint::<DiemVM>(&db_rw, &gen_tx)
        .map_err(|e| Error::UnexpectedError(e.to_string()))
}

//////// 0L ////////
pub fn extract_waypoint(gen_tx: Transaction) -> Result<Waypoint, Error> {
    let path = TempPath::new();
    let libradb = DiemDB::open(&path, false, None, RocksdbConfig::default())
        .map_err(|e| Error::UnexpectedError(e.to_string()))?;
    let db_rw = DbReaderWriter::new(libradb);

    db_bootstrapper::generate_waypoint::<DiemVM>(&db_rw, &gen_tx)
        .map_err(|e| Error::UnexpectedError(e.to_string()))
}
