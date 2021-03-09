//! `bal` subcommand

use cli::libra_client::LibraClient;
use reqwest::Url;
use anyhow::Error;
use anyhow::{Result};
use libra_json_rpc_client::views::MetadataView;
use crate::{
    prelude::app_config,
    client::make_client,
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
    pub fn new(url: Url, mut client: LibraClient) -> Result<Metadata, Error> {    
        let block_metadata = client
        .get_metadata()
        .unwrap_or_else(|e| {
            panic!(
                "Not able to connect to validator at {:#?}. Error: {}",
                &url,
                e,
            )
        });
        Ok(Metadata {
            url: url,
            meta: block_metadata
        })
    }

    /// Compare the metadata of a local and a remote node
    pub fn compare(local: Metadata, remote: Metadata) -> i64 {
        // if local.meta.version > remote.meta.version { return 0 };
        let delay: i64 = local.meta.version as i64 - remote.meta.version as i64;

        // fn ledger_info_str(m: &Metadata) -> String { format!(
        //         "latest height: {} URL: {:#?} timestamp: {}",
        //         m.meta.version,
        //         m.url,
        //         DateTime::<Utc>::from(UNIX_EPOCH + Duration::from_micros(m.meta.timestamp))
        //     )
        // }   

        // println!("LOCAL: {:#?}", ledger_info_str(&local));
        // println!("REMOTE: {:#?}", ledger_info_str(&remote));
        // println!("Local Delay: {:#?}", &delay);
        delay
    }

    /// Compare the nodes from toml config.
    pub fn compare_from_config() -> i64 {
        let config = app_config();
        let local_url = config.upstream_node_url.clone();
        let remote_url = config.upstream_node_url.clone();
        let waypoint = config.base_wapoint.clone();

        let local = Metadata::new(
            local_url.clone(),
            make_client(
                Some(local_url), 
                waypoint
            ).unwrap()
        ).unwrap();

        let remote = Metadata::new(
            remote_url.clone(),
            make_client(
               Some(remote_url), 
                waypoint
            ).unwrap()
        ).unwrap();

        Metadata::compare(local, remote) as i64
    }
    
}
