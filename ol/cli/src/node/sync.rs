//! `sync` subcommand

use super::node::Node;
use crate::node::client::*;
use anyhow::{bail, Error};
use backup_cli::utils::backup_service_client::{BackupServiceClient, BackupServiceClientOpt};
use diemdb::backup::backup_handler::DbState;
use tokio::runtime::Runtime;

/// State of the node's sync
#[derive(Debug)]
pub struct SyncState {
    /// if synced
    pub is_synced: bool,
    /// local height of database
    pub sync_height: u64,
    /// remote database height
    pub remote_height: u64,
    /// delay in blocks between remote and local
    pub sync_delay: i64,
}

impl Default for SyncState {
    fn default() -> Self {
        SyncState {
            is_synced: false,
            sync_height: 0,
            remote_height: 0,
            sync_delay: 0,
        }
    }
}
impl Node {
    /// check if node is synced
    pub fn check_sync(&mut self) -> Result<SyncState, Error> {
        let mut s = SyncState::default();

        if !Node::node_running() {
            // this should not fail for `ol start` command. The node is usually off when the command and sync is checked.
            return Ok(SyncState {
                is_synced: false,
                sync_height: 0,
                remote_height: 0,
                sync_delay: 404,
            });
        }
        // let config = &self.app_conf;
        let waypoint = &self.waypoint()?;

        let remote_client = find_a_remote_jsonrpc(&self.app_conf, *waypoint).map_err(|e| {
            println!("cannot connect to upstream node");
            e
        })?;

        let local_db = self.get_db_state()?;
        s.remote_height = match remote_client.get_metadata() {
            Ok(m) => m.version,
            Err(_) => 404,
        };
        s.sync_height = local_db.synced_version;
        s.sync_delay = s.remote_height as i64 - s.sync_height as i64;
        s.is_synced = s.sync_delay < 1000;
        Ok(s)
    }

    // /// check if node is synced
    // pub fn sync_state(&mut self) -> Result<SyncState, Error> {
    //   self.check_sync()
    // }
    /// get local sync block height
    pub fn get_db_state(&self) -> Result<DbState, Error> {
        // if is swarm need to get the backup_service_address: "127.0.0.1:44867" from the NodeConfig in swarm_temp/0/node.yaml
        if let Some(cfg) = &self.node_conf {
            let url_string = format!("http://{}", cfg.storage.backup_service_address);
            let bk = BackupServiceClientOpt {
                address: url_string,
            };
            let client = BackupServiceClient::new_with_opt(bk);

            let rt = Runtime::new().unwrap();
            match rt.block_on(client.get_db_state())? {
                Some(db) => return Ok(db),
                None => {}
            }
        }
        bail!("could not load backup_service_address from node.yaml")
    }
}
