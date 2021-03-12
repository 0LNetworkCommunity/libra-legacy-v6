//! `bal` subcommand

use cli::libra_client::LibraClient;
use reqwest::Url;
use libra_json_rpc_client::views::MetadataView;
use crate::{
    client::*,
};
/// Get chain Metadata
#[derive(Debug)]
pub struct Metadata {
    url: Url,
    meta: MetadataView,
}


impl Metadata {
    /// returns a LibraClient instance.
    // TODO: Use app config file for params
    pub fn new(url: Url, mut client: LibraClient) -> Self {    
        let block_metadata = client
        .get_metadata()
        .unwrap_or_else(|e| {
            panic!(
                "Not able to connect to validator at {:#?}. Error: {}",
                &url,
                e,
            )
        });
        Metadata {
            url: url,
            meta: block_metadata
        }
    }

    /// Compare the metadata of a local and a remote node
    pub fn compare(local: Metadata, remote: Metadata) -> i64 {
        let delay: i64 = local.meta.version as i64 - remote.meta.version as i64;
        delay
    }

    /// Compare the nodes from toml config.
    pub fn compare_from_config() -> i64 {

        let local_client = default_local_client();
        let local = Metadata::new(
            local_client.1,
            local_client.0.unwrap()
        );

        let remote_client = default_remote_client();

        let remote = Metadata::new(
            remote_client.1,
            remote_client.0.unwrap()
        );

        Metadata::compare(local, remote) as i64
    }

    // pub fn get_waypoint_upstream() -> Waypoint {
    //     // let client = default_remote_client().0.unwrap();
    //     // let li = client
    //     // .latest_epoch_change_li_ol()
    //     // .unwrap()
    //     // .ledger_info()
    //     // .clone();

    //     // Waypoint::new_any(&li)
    // }
    
}
