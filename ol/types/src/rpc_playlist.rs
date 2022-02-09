//! seed peers for connecting to various networks.
use anyhow::Error;
use serde::{Deserialize};
use url::Url;

#[derive(Deserialize)]
pub struct FullnodePlaylist {
    ///
    pub nodes: Vec<HostInfo>
}

#[derive(Deserialize)]
pub struct HostInfo {
    ///
    pub note: String,
    ///
    pub url: Url,
}

// try to fetch current fullnodes for mainnet from github
pub fn get_known_fullnodes(seed_url: Option<Url>) -> Result<Vec<HostInfo>, Error> {

  //TODO: Move this default elsewhere, possibly duplicated with src/components/settings/SetNetworkPlaylist.svelte
  let url = seed_url.unwrap_or("https://raw.githubusercontent.com/OLSF/carpe/main/seed_peers/fullnode_seed_playlist.json".parse().unwrap());

  Ok(FullnodePlaylist::http_fetch_playlist(url)?.nodes)
}

impl FullnodePlaylist {
  // extract the urls
  pub fn get_urls(&self) -> Vec<Url>{
    self.nodes.iter()
    .filter_map(|a| {
      Some(a.url.to_owned())
    })
    .collect()
  }

  pub fn http_fetch_playlist(url: Url) -> Result<FullnodePlaylist, Error> {
    let res = reqwest::blocking::get(url)?;
    let play: FullnodePlaylist = serde_json::from_str(&res.text()?)?;//res.text()?.parse()?;
    Ok(play)
  }
}