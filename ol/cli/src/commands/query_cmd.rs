//! `bal` subcommand

use crate::{
    entrypoint,
    node::client,
    node::node::Node,
    node::query::{is_community_wallet, is_slow_wallet, QueryType, WalletType},
    prelude::app_config,
};
use abscissa_core::{status_info, Command, Options, Runnable};
use move_core_types::account_address::AccountAddress;
use std::process::exit;

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

    #[options(short = "u", help = "unlocked balance")]
    unlocked_balance: bool,

    #[options(no_short, help = "blockheight")]
    blockheight: bool,

    #[options(help = "sync delay from upstream")]
    sync: bool,

    #[options(help = "resources")]
    resources: bool,

    #[options(help = "epoch and waypoint")]
    epoch: bool,

    #[options(help = "get last transactions, defaults to last 100")]
    txs: bool,

    #[options(help = "get last payment events SENT, defaults to last 100")]
    events_sent: bool,

    #[options(help = "get last payment events RECEIVED, defaults to last 100")]
    events_received: bool,

    #[options(help = "height to start txs query from, defaults to -100_000 blocks")]
    txs_height: Option<u64>,

    #[options(help = "number of txs to return, defaults to 100 txs")]
    txs_count: Option<u64>,

    #[options(help = "filter by type of transaction, e.g. 'ol_miner_state_commit'")]
    txs_type: Option<String>,

    #[options(help = "move value")]
    move_state: bool,

    #[options(help = "move module name")]
    move_module: Option<String>,

    #[options(help = "move struct name")]
    move_struct: Option<String>,

    #[options(help = "move value name")]
    move_value: Option<String>,

    #[options(help = "Get a validator's on-chain config")]
    val_config: bool,
}

impl Runnable for QueryCmd {
    fn run(&self) {
        let args = entrypoint::get_args();
        let is_swarm = *&args.swarm_path.is_some();
        let mut cfg = app_config().clone();
        let account = if args.account.is_some() {
            args.account.unwrap()
        } else {
            cfg.profile.account
        };
        let client = client::pick_client(args.swarm_path.clone(), &mut cfg).unwrap_or_else(|e| {
            println!("ERROR: Cannot connect to a client. Message: {}", e);
            exit(1);
        });
        let mut node = Node::new(client, &cfg, is_swarm);
        let mut display = "";
        let mut query_type = QueryType::Balance { account };

        if self.balance {
            query_type = QueryType::Balance { account };
            display = "BALANCE";
        } else if self.unlocked_balance {
            query_type = QueryType::UnlockedBalance { account };
            display = "UNLOCKED BALANCE";
        } else if self.blockheight {
            query_type = QueryType::BlockHeight;
            display = "BLOCK HEIGHT";
        } else if self.sync {
            query_type = QueryType::SyncDelay;
            display = "SYNC";
        } else if self.resources {
            query_type = QueryType::Resources { account };
            display = "RESOURCES";
        } else if self.move_state {
            query_type = QueryType::MoveValue {
                account,
                module_name: self.move_module.clone().unwrap(),
                struct_name: self.move_struct.clone().unwrap(),
                key_name: self.move_value.clone().unwrap(),
            };
            display = "RESOURCES";
        } else if self.epoch {
            query_type = QueryType::Epoch;
            display = "EPOCH";
        } else if self.events_received {
            query_type = QueryType::Events {
                account,
                sent_or_received: false,
                seq_start: self.txs_height,
            };
            display = "EVENTS";
        } else if self.events_sent {
            query_type = QueryType::Events {
                account,
                sent_or_received: true,
                seq_start: self.txs_height,
            };
            display = "EVENTS";
        } else if self.txs {
            query_type = QueryType::Txs {
                account,
                txs_height: self.txs_height,
                txs_count: self.txs_count,
                txs_type: self.txs_type.to_owned(),
            };
            display = "TRANSACTIONS";
        } else if self.val_config {
            query_type = QueryType::ValConfig { account };
            display = "VALIDATOR CONFIGS";
        }

        match node.query(query_type) {
            Ok(info) => {
                status_info!(display, format!("{}", info));
            }
            Err(e) => {
                println!("could not query node, exiting. Message: {:?}", e);
                exit(1);
            }
        };
    }
}

/// get wallet type
pub fn get_wallet_type(account: AccountAddress, node: Node) -> WalletType {
    match node.get_annotate_account_blob(account) {
        Ok((Some(r), _)) => {
            if is_slow_wallet(&r) {
                return WalletType::Slow;
            }
            if is_community_wallet(&r) {
                return WalletType::Community;
            }
            WalletType::None
        }
        _ => WalletType::None,
    }
}
