//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable, status_info};
use crate::{
    entrypoint,
    prelude::app_config,
    node::query::QueryType,
    node::client,
    node::node::Node
};

/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Default, Options)]
pub struct QueryCmd {
    #[options(short = "b", help = "balance")]
    balance: bool,

    #[options(no_short, help = "blockheight")]
    blockheight: bool,
    
    #[options(help = "sync delay")]
    sync_delay: bool,
    
    #[options(help = "resources")]
    resources: bool,

    #[options(help = "epoch and waypoint")]
    epoch: bool,
}

impl Runnable for QueryCmd {
    fn run(&self) {
        let args = entrypoint::get_args();
        let cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &cfg).unwrap().0;
        let mut node = Node::new(client, cfg);

        let _account = 
            if args.account.is_some() { args.account.unwrap() }
            else { app_config().profile.account };

        let mut info = String::new();
        let mut display = "";

        // TODO: Reduce boilerplate. Serialize "balance" to cast to QueryType::Balance        
        if self.balance {
            info = node.get(QueryType::Balance);
            display = "BALANCE";
        } 
        else if self.blockheight {
            info = node.get(QueryType::BlockHeight);
            display = "BLOCKHEIGHT";
        }
        else if self.sync_delay {
            info = node.get(QueryType::SyncDelay);
            display = "SYNC-DELAY";
        } 
        else if self.resources {
            info = node.get(QueryType::Resources);
            display = "RESOURCES";
        }
        else if self.resources {
            info = node.get(QueryType::Epoch);
            display = "EPOCH";
        }

        status_info!(display, format!("{}", info));
    }
}
