//! resfresh peers

use std::path::PathBuf;

use crate::node::node::Node;
use anyhow::{bail, Error};
use diem_types::network_address::NetworkAddress;
use ol_types::config::parse_toml;
use reqwest::Url;

impl Node {
    /// refresh the fullnode peers, and save to file
    pub fn refresh_peers_update_toml(&mut self, cfg_path: PathBuf) -> Result<(), Error> {
        let mut cfg =
            parse_toml(cfg_path.to_str().unwrap().to_string()).expect("could not parse toml");

        let url_list: Vec<Url>;

        match &self.vitals.chain_view {
            Some(v) => {
                url_list = v
                    .validator_view
                    .as_ref()
                    .unwrap()
                    .into_iter()
                    .filter_map(|a| match a.full_node_ip.parse::<NetworkAddress>() {
                        Ok(n) => n.find_ip_addr(),
                        Err(_) => None,
                    })
                    .filter_map(|a| {
                        let mut u = Url::parse("http://localhost").unwrap();
                        u.set_ip_host(a).ok();
                        u.set_port(Some(8080)).ok();
                        Some(u)
                    })
                    .collect();

                if url_list.len() > 0 {
                    cfg.profile.upstream_nodes = Some(url_list);
                    cfg.save_file();
                }

                return Ok(());
            }
            None => bail!("error retrieving chain view"),
        }
    }
}
