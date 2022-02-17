//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable, status_info};
use crate::{
    entrypoint,
    prelude::app_config,
    node::query::{QueryType, WalletType, find_value_from_state, find_value_in_struct},
    node::client,
    node::node::Node
};
use std::process::exit;
use move_core_types::{
    account_address::AccountAddress,
    language_storage::TypeTag
};
use resource_viewer::AnnotatedMoveValue::{Bool, U64, Vector};

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
        let account = 
            if args.account.is_some() { args.account.unwrap() }
            else { cfg.profile.account };
        let client = client::pick_client(
            args.swarm_path.clone(), &mut cfg
        ).unwrap_or_else(|e| {
            println!("ERROR: Cannot connect to a client. Message: {}", e);
            exit(1);
        });
        let mut node = Node::new(client, &cfg, is_swarm);
        let mut display = "";
        let mut query_type = QueryType::Balance{account};

        if self.balance {
            query_type = QueryType::Balance{account};
            display = "BALANCE";
        }
        else if self.blockheight {
            query_type = QueryType::BlockHeight;
            display = "BLOCK HEIGHT";
        }
        else if self.sync {
            query_type = QueryType::SyncDelay;
            display = "SYNC";
        }
        else if self.resources {
            query_type = QueryType::Resources{account};
            display = "RESOURCES";
        }
        else if self.move_state {
            query_type = QueryType::MoveValue{
              account,
              module_name: self.move_module.clone().unwrap(),
              struct_name: self.move_struct.clone().unwrap(),
              key_name: self.move_value.clone().unwrap(),
            };
            display = "RESOURCES";
        }
        else if self.epoch {
            query_type = QueryType::Epoch;
            display = "EPOCH";
        } else if self.events_received {
            
            query_type = QueryType::Events{
                account, sent_or_received: false, seq_start: self.txs_height
            };
            display = "EVENTS";
        } else if self.events_sent {
            query_type = QueryType::Events{
                account, sent_or_received: true, seq_start: self.txs_height
            };
            display = "EVENTS";
        }
        else if self.txs {
            query_type = 
              QueryType::Txs {
                account,
                txs_height: self.txs_height,
                txs_count: self.txs_count, 
                txs_type: self.txs_type.to_owned(),
              };
            display = "TRANSACTIONS";
        }
        else if self.val_config {
            query_type = 
              QueryType::ValConfig {
                account,
              };
            display = "VALIDATOR CONFIGS";
        }

        match node.query(query_type) {
            Ok(info) => {
              status_info!(display, format!("{}", info));
            },
            Err(e) => {
              println!("could not query node, exiting. Message: {:?}", e);
              exit(1);
            },
        };
    }
}

pub fn get_wallet_type(account: AccountAddress, mut node: Node) -> WalletType {
    match node.get_annotate_account_blob(account) {
        Ok((Some(r), _)) => {
            let slow_module_name = "DiemAccount";
            let slow_struct_name = "SlowWallet";
            let unlocked = find_value_from_state(
                &r,
                slow_module_name.to_string(),
                slow_struct_name.to_string(),
                "unlocked".to_string());
            let transferred = find_value_from_state(
                &r,
                slow_module_name.to_string(),
                slow_struct_name.to_string(),
                "transferred".to_string());
            if let (Some(U64(0)), Some(U64(0))) = (unlocked, transferred) {
                dbg!(WalletType::Slow);
                return WalletType::Slow;
            }

            let community_module_name = "Wallet";
            let community_struct_name = "CommunityFreeze";
            let is_frozen = find_value_from_state(
                &r,
                community_module_name.to_string(),
                community_struct_name.to_string(),
                "is_frozen".to_string());
            let consecutive_rejections = find_value_from_state(
                &r,
                community_module_name.to_string(),
                community_struct_name.to_string(),
                "consecutive_rejections".to_string());
            let unfreeze_votes = find_value_from_state(
                &r,
                community_module_name.to_string(),
                community_struct_name.to_string(),
                "unfreeze_votes".to_string());
            if let (Some(Bool(false)), Some(U64(0)), Some(Vector(TypeTag::Address, vec))) = (is_frozen, consecutive_rejections, unfreeze_votes) {
                if vec.len() == 0 {
                    dbg!(WalletType::Community);
                    return WalletType::Community;
                }
            }
            dbg!(WalletType::None);
            WalletType::None
        },
        _ => {
            dbg!(WalletType::None);
            WalletType::None
        },
    }
}
