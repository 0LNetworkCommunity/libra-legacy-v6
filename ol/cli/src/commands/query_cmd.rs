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
    
    #[options(help = "sync delay from upstream")]
    sync: bool,
    
    #[options(help = "resources")]
    resources: bool,

    #[options(help = "epoch and waypoint")]
    epoch: bool,

    #[options(help = "get last 100 transactions")]
    txs: bool,

    #[options(help = "height to start txs query from, defaults to -100_000 blocks")]
    txs_height: Option<u64>,

    #[options(help = "number of txs to return, defaults to 100 txs")]
    txs_count: Option<u64>,

    #[options(help = "filter by type of transaction, e.g. 'ol_miner_state_commit'")]
    txs_type: Option<String>,

}

impl Runnable for QueryCmd {
    fn run(&self) {
        let args = entrypoint::get_args();
        let is_swarm = *&args.swarm_path.is_some();
        let mut cfg = app_config().clone();
        let client = client::pick_client(args.swarm_path, &mut cfg).unwrap().0;
        let mut node = Node::new(client, cfg, is_swarm);

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
            display = "BLOCK HEIGHT";
        }
        else if self.sync {
            info = node.get(QueryType::SyncDelay);
            display = "SYNC";
        } 
        else if self.resources {
            info = node.get(QueryType::Resources);
            display = "RESOURCES";
        }
        else if self.epoch {
            info = node.get(QueryType::Epoch);
            display = "EPOCH";
        }
        else if self.txs {
            info = node.get(QueryType::Txs {
              account: args.account,
              txs_height: self.txs_height,
              txs_count: self.txs_count, 
              txs_type: self.txs_type.to_owned(),
            });
            display = "TRANSACTIONS";
        }
        status_info!(display, format!("{}", info));
    }
}
