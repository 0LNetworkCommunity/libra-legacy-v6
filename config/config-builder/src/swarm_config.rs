// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use anyhow::Result;
use libra_config::config::NodeConfig;
// use libra_crypto::ed25519::Ed25519PrivateKey;
use libra_types::waypoint::Waypoint;
use std::path::PathBuf;

pub trait BuildSwarm {
    /// Generate the configs for a swarm
    fn build_swarm(&self) -> Result<Vec<NodeConfig>>;
}

pub struct SwarmConfig {
    pub config_files: Vec<PathBuf>,
    pub waypoint: Waypoint,
}

impl SwarmConfig {
    pub fn build<T: BuildSwarm>(config_builder: &T, output_dir: &PathBuf) -> Result<Self> {
        let mut configs = config_builder.build_swarm()?;
        let mut config_files = vec![];

        for (index, config) in configs.iter_mut().enumerate() {
            let node_dir = output_dir.join(index.to_string());
            std::fs::create_dir_all(&node_dir)?;

            let node_path = node_dir.join("node.config.toml");
            config.set_data_dir(node_dir);
            config.save(&node_path)?;
            config_files.push(node_path);
        }

        Ok(SwarmConfig {
            config_files,
            waypoint: configs[0].base.waypoint.waypoint_from_config().unwrap(),
        })
    }
}
