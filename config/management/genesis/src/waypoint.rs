// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use std::path::PathBuf;

use executor::db_bootstrapper;
use libra_management::{config::ConfigPath, error::Error, secure_backend::SharedBackend};
use libra_temppath::TempPath;
use libra_types::{chain_id::ChainId, transaction::Transaction, waypoint::Waypoint};
use libra_vm::LibraVM;
use libradb::LibraDB;
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
    genesis_path: Option<PathBuf>,

    //////// 0L /////////
    #[structopt(long)]
    pub genesis_blob_path: Option<PathBuf>,
}

impl CreateWaypoint {
    pub fn execute(self) -> Result<Waypoint, Error> {
        let genesis_helper = crate::genesis::Genesis {
            config: self.config,
            chain_id: self.chain_id,
            backend: self.shared_backend,
            //////// 0L ////////
            path: self.genesis_path,
            genesis_blob_path: self.genesis_blob_path
        };

        let gen_tx = genesis_helper.execute()?;
        Self::extract_waypoint(gen_tx)

    }
    pub fn extract_waypoint(gen_tx: Transaction) -> Result<Waypoint, Error> {
        let path = TempPath::new();
        let libradb =
            LibraDB::open(&path, false, None).map_err(|e| Error::UnexpectedError(e.to_string()))?;
        let db_rw = DbReaderWriter::new(libradb);

        db_bootstrapper::generate_waypoint::<LibraVM>(&db_rw, &gen_tx)
            .map_err(|e| Error::UnexpectedError(e.to_string()))
    }
}

