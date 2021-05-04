//! `mgmt` subcommand

use crate::{application::app_config, entrypoint, mgmt::management::NodeMode, node::{client, node::Node}};
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
        let cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &cfg).unwrap().0;
        let mut node = Node::new(client, cfg);

        if self.start_node {
            node.start_node(NodeMode::Fullnode).expect("could not start fullnode");
        } else if self.stop_node {
            node.stop_node();
        } else if self.start_miner {
            node.start_miner();
        } else if self.stop_miner {
            node.stop_miner();
        } else if self.stop_all {
            node.stop_node();
            node.stop_miner();
        }
    }
}
