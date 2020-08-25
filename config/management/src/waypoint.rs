// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{error::Error, SecureBackends, SingleBackend};
use executor::db_bootstrapper;
use libra_secure_storage::{Storage, Value};
use libra_temppath::TempPath;
// use libra_types::waypoint::Waypoint;
use libra_types::waypoint::Waypoint;

use libra_vm::LibraVM;
use libradb::LibraDB;
use std::{path::PathBuf, convert::TryInto, fs::File, io::Write};
use storage_interface::DbReaderWriter;
use structopt::StructOpt;

/// Produces a waypoint from Genesis by either building it from a remote share or a local file. It
/// then computes the Waypoint and optionally inserts it into another storage.
#[derive(Debug, StructOpt)]
pub struct CreateWaypoint {
    #[structopt(flatten)]
    secure_backends: SecureBackends,
    #[structopt(long)]
    path: Option<PathBuf>,
}

impl CreateWaypoint {
    pub fn execute(self) -> Result<Waypoint, Error> {
        if let Some(remote) = self.secure_backends.remote {
            let genesis_helper = crate::genesis::Genesis {
                backend: SingleBackend {
                    backend: remote.clone(),
                },
                path: None,
            };
            let genesis = genesis_helper.execute()?;

            let path = TempPath::new();
            let libradb = LibraDB::open(&path, false, None)
                .map_err(|e| Error::UnexpectedError(e.to_string()))?;
            let db_rw = DbReaderWriter::new(libradb);

            let waypoint = db_bootstrapper::bootstrap_db_if_empty::<LibraVM>(&db_rw, &genesis)
                .map_err(|e| Error::UnexpectedError(e.to_string()))?
                .ok_or_else(|| {
                    Error::UnexpectedError("Unable to generate a waypoint".to_string())
                })?;

            let mut local: Box<dyn Storage> = self.secure_backends.local.try_into()?;
            local
                .available()
                .map_err(|e| Error::LocalStorageUnavailable(e.to_string()))?;

            let waypoint_value = Value::String(waypoint.to_string());
            local
                .set(libra_global_constants::WAYPOINT, waypoint_value)
                .map_err(|e| {
                    Error::RemoteStorageWriteError(libra_global_constants::WAYPOINT, e.to_string())
                })?;

            let mut remote: Box<dyn Storage> = remote.try_into()?;
            remote
                .available()
                .map_err(|e| Error::RemoteStorageUnavailable(e.to_string()))?;

            let waypoint_value = Value::String(waypoint.to_string());
            remote
                .set(libra_global_constants::WAYPOINT, waypoint_value)
                .map_err(|e| {
                    Error::RemoteStorageWriteError(libra_global_constants::WAYPOINT, e.to_string())
                })?;

            let path: PathBuf;

            if self.path.is_none() {
                path = PathBuf::from("./");
            } else {
                path = self.path.unwrap();
            }

            let mut file = File::create(path.join("genesis_waypoint.txt")).unwrap();
            file.write_all(&waypoint.to_string().as_bytes() );

            return Ok(waypoint);
        }

        Err(Error::RemoteStorageWriteError(
            libra_global_constants::WAYPOINT,
            "No remote backend set".to_string(),
        ))
    }
}
