//! `bal` subcommand

use cli::libra_client::LibraClient;
use reqwest::Url;
use anyhow::Error;
use anyhow::{Result};

use libra_json_rpc_client::views::MetadataView;


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
    pub fn compare(local: Metadata, remote: Metadata) {
        dbg!(local);
        dbg!(remote);

    }
    
}
