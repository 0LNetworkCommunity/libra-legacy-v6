//! `bal` subcommand

use cli::libra_client::LibraClient;
use reqwest::Url;
use libra_json_rpc_client::views::MetadataView;
use crate::{client::*, config::OlCliConfig};
/// Get chain Metadata
#[derive(Debug)]
pub struct Metadata {
    /// url
    pub url: Url,
    /// metadata object
    pub meta: Option<MetadataView>,
}


impl Metadata {
    /// returns a LibraClient instance.
    // TODO: Use app config file for params
    pub fn new(url: &Url, client: &mut LibraClient) -> Self {    
        match client.get_metadata() {
            Ok(meta) => {
                Metadata {
                    url: url.clone(),
                    meta: Some(meta)
                }
            }
            Err(_) => {
                Metadata {
                    url: url.clone(),
                    meta: None
                }
            }
        }

    }

    /// Compare the metadata of a local and a remote node
    pub fn compare(local: MetadataView, remote: MetadataView) -> i64 {
        let delay: i64 =  remote.version as i64 - local.version as i64;
        delay
    }

    /// Compare the nodes from toml config.
    pub fn compare_from_config(config: &OlCliConfig) -> i64 {

        let local_client = default_local_client(config);
        let local = Metadata::new(
            &local_client.1,
            &mut local_client.0.unwrap()
        );

        let remote_client = default_remote_client(config);

        let remote = Metadata::new(
            &remote_client.1,
            &mut remote_client.0.unwrap()
        );
        if local.meta.is_some() && remote.meta.is_some() {
         return Metadata::compare(local.meta.unwrap(), remote.meta.unwrap()) as i64
        }
        0
    }
}
