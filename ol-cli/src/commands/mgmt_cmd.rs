//! `mgmt` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::management::{self, NodeType};

/// `mgmt` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct MgmtCmd {
    #[options(no_short, help = "start node")]
    start_node: bool,

    #[options(no_short, help = "stop node")]
    stop_node: bool,

    #[options(no_short, help = "start miner")]
    start_miner: bool,
}

impl Runnable for MgmtCmd {
    fn run(&self) {
        // management::fetch_backups().unwrap();
        if self.start_node {
            management::start_node(NodeType::Fullnode).expect("could not start fullnode");
        } 
        else if self.stop_node {
            management::stop_node();            
        } 
        else if self.start_miner {
            management::start_miner();
        }
    }
}
