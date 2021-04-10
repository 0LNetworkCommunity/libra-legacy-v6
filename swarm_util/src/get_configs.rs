//! `get_configs`
use libra_config::config::NodeConfig;
use std::path::PathBuf;
use reqwest::Url;
use libra_types::waypoint::Waypoint;

/// Get swarm configs from swarm files, swarm must be running
pub fn get_swarm_configs(mut swarm_path: PathBuf) -> (Url, Waypoint) {
    swarm_path.push("0/node.yaml");
    let config = NodeConfig::load(&swarm_path).unwrap_or_else(
        |_| panic!("Failed to load NodeConfig from file: {:?}", &swarm_path)
    );

    let url =  Url::parse(
        format!("http://localhost:{}", config.json_rpc.address.port()).as_str()
    ).unwrap();

    let waypoint = config.base.waypoint.waypoint();

    (url, waypoint)
}