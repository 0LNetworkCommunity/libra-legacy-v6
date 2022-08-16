//! `bal` subcommand

use crate::{config::AppCfg, node::node::Node, prelude::app_config};
use anyhow::Error;
use anyhow::Result;
use diem_client::BlockingClient as DiemClient;
use rand::prelude::SliceRandom;
use rand::thread_rng;
use reqwest::Url;
use std::path::PathBuf;

/// returns a DiemClient instance.
// TODO: Use app config file for params
pub fn make_client(url: Option<Url>) -> Result<DiemClient, Error> {
    match url {
        Some(u) => Ok(DiemClient::new(u)),
        None => Ok(DiemClient::new(
            Url::parse("http://localhost:8080").expect("Couldn't create diem client"),
        )),
    }
}

/// Experimental
pub fn get_client() -> Option<DiemClient> {
    let config = app_config();
    for url in &config.profile.upstream_nodes {
        let client = DiemClient::new(url.clone());
        // TODO: What's the better way to check we can connect to client?
        let metadata = client.get_metadata();
        if metadata.is_ok() {
            // found a connect-able upstream node
            return Some(client);
        }
    }

    None
}

/// get client type with defaults from toml for remote node
pub fn find_a_remote_jsonrpc(config: &AppCfg) -> Result<DiemClient, Error> {
    let mut rng = thread_rng();
    let list = &config.profile.upstream_nodes;
    let len = list.len();
    let url = list
        .choose_multiple(&mut rng, len)
        .into_iter()
        .find(|&remote_url| {
            match make_client(Some(remote_url.to_owned())) {
                Ok(c) => match c.get_metadata() {
                    Ok(response) => {
                        let metadata = response.into_inner();
                        if metadata.version > 0 {
                            true
                        } else {
                            println!("can make client but could not get blockchain height > 0");
                            false
                        }
                    }
                    Err(e) => {
                        println!("can make client but could not get metadata {:?}", e);
                        false
                    }
                },
                Err(e) => {
                    println!("could not make client {:?}", e);
                    false
                }
            }
        });

    if let Some(url_clean) = url {
        return make_client(Some(url_clean.to_owned()));
    };
    Err(Error::msg(
        format!("Cannot connect to any JSON RPC peers in the list of upstream_nodes in 0L.toml {:?}", list)
    ))
}

/// the default client will be the first option in the list.
pub fn default_local_rpc() -> Result<DiemClient, Error> {
    make_client("127.0.0.1".parse().ok())
}

/// connect a swarm client
pub fn swarm_test_client(swarm_path: PathBuf) -> Result<DiemClient, Error> {
    let (url, _) = ol_types::config::get_swarm_rpc_url(swarm_path.clone());
    make_client(Some(url.clone()))
}

/// picks what URL to connect to based on sync state. Or returns the client for swarm.
pub fn pick_client(swarm_path: Option<PathBuf>, config: &mut AppCfg) -> Result<DiemClient, Error> {
    let is_swarm = *&swarm_path.is_some();
    if let Some(path) = swarm_path {
        return swarm_test_client(path);
    };

    // check if is in sync
    let local_client = default_local_rpc()?;

    let remote_client = find_a_remote_jsonrpc(config)?;
    // compares to an upstream random remote client. If it is synced, use the local client as the default
    let mut node = Node::new(local_client, config, is_swarm);
    match node.check_sync(){
        Ok(a) => { 
          match a.is_synced {
            true => Ok(node.client),
            false => Ok(remote_client),
          }
        },
        _ => Ok(remote_client),
    }
}
