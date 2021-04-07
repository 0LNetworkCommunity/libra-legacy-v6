//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable, status_info};
use crate::{
    commands,
    entrypoint,
    prelude::app_config,
    query::{get, QueryType},
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
}

impl Runnable for QueryCmd {
    fn run(&self) {
        let args = entrypoint::get_args();
        let account = 
            if args.account.is_some() { args.account.unwrap() }
            else { app_config().profile.account };

        let mut info = String::new();
        let mut display = "";



        // TODO: Reduce boilerplate. Serialize "balance" to cast to QueryType::Balance        
        if self.balance {
            info = get(QueryType::Balance, account);
            display = "BALANCE";
        } 
        else if self.blockheight {
            info = get(QueryType::BlockHeight, account);
            display = "BLOCKHEIGHT";
        }
        else if self.sync_delay {
            info = get(QueryType::SyncDelay, account);
            display = "SYNC-DELAY";
        } 
        else if self.resources {
            info = get(QueryType::Resources, account);
            display = "RESOURCES";
        }

        status_info!(display, format!("{}", info));
    }
}
