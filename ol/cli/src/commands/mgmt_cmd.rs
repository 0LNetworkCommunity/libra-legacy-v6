//! `mgmt` subcommand

use crate::{
    application::app_config,
    entrypoint,
    node::{client, node::Node},
};
use abscissa_core::{Command, Options, Runnable};

/// management subcommands
#[derive(Command, Debug, Options)]
pub struct MgmtCmd {
    #[options(no_short, help = "start node")]
    start_node: bool,

    #[options(no_short, help = "stop node")]
    stop_node: bool,

    #[options(no_short, help = "start miner")]
    start_miner: bool,

    #[options(no_short, help = "stop miner")]
    stop_miner: bool,

    #[options(no_short, help = "stop node and miner")]
    stop_all: bool,
}

impl Runnable for MgmtCmd {
    fn run(&self) {
        let args = entrypoint::get_args();
        let is_swarm = *&args.swarm_path.is_some();
        let mut cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &mut cfg).unwrap();
        let mut node = Node::new(client, &cfg, is_swarm);

        if self.start_node {
            node.start_node(true).expect("could not start fullnode");
        } else if self.stop_node {
            node.stop_node();
        } else if self.start_miner {
            node.start_miner(true);
        } else if self.stop_miner {
            node.stop_miner();
        } else if self.stop_all {
            node.stop_node();
            node.stop_miner();

            // also stop pilot and monitor.
            let mut child = std::process::Command::new("killall")
                .arg("ol")
                .spawn()
                .expect(&format!("failed to run killall ol"));
            child.wait().expect("killall did not exit");
        }
    }
}
