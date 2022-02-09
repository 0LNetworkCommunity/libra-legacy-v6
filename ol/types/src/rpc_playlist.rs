//! seed peers for connecting to various networks.
use anyhow::Error;
use serde::{Deserialize};
use url::Url;

#[derive(Deserialize)]
/// A list of host information for upstream fullnodes serving RPC servers
pub struct FullnodePlaylist {
    ///
    pub nodes: Vec<HostInfo>
}

#[derive(Deserialize)]
/// infor for the RPC peers connection.
pub struct HostInfo {
    ///
    pub note: String,
    ///
    pub url: Url,
}

/// try to fetch current fullnodes from a URL, or default to a seed peer list
pub fn get_known_fullnodes(seed_url: Option<Url>) -> Result<FullnodePlaylist, Error> {
  let url = seed_url.unwrap_or("https://raw.githubusercontent.com/OLSF/seed-peers/main/fullnode_seed_playlist.json".parse().unwrap());

  FullnodePlaylist::http_fetch_playlist(url)
}

impl FullnodePlaylist {
  /// use a URL to load a fullnode playlist
  pub fn http_fetch_playlist(url: Url) -> Result<FullnodePlaylist, Error> {
    let res = reqwest::blocking::get(url)?;
    let play: FullnodePlaylist = serde_json::from_str(&res.text()?)?;//res.text()?.parse()?;
    Ok(play)
  }

    /// extract the urls from the playlist struct
  pub fn get_urls(&self) -> Vec<Url>{
    self.nodes.iter()
    .filter_map(|a| {
      Some(a.url.to_owned())
    })
    .collect()
  }
}