//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable, status_info};
use crate::{
    query::{get, QueryType},
    prelude::app_config,
};
use libra_types::{account_address::AccountAddress};

/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Default, Options)]
pub struct QueryCmd {
    // TODO: This should be an entrypoint arg, not subcommand
    #[options(short = "a", help = "account to query")]
    account: Option<AccountAddress>,

    // "free" arguments don't have an associated flag
    #[options(free)]
    free_args: Vec<String>,
}

impl Runnable for QueryCmd {
    fn run(&self) {
        let config = app_config().clone();
        // let account = if 
        let account = if self.account.is_some() { self.account.unwrap() } 
        else { config.profile.account };

        let mut info = "".to_owned();
        let mut display = "".to_owned();
        
        // TODO: Reduce boilerplate. Serialize "balance" to cast to QueryType::Balance
        let arg_exists = |s: &str| self.free_args.contains(&s.to_string());
        if arg_exists("balance") {
            info = get(QueryType::Balance, account);
            display = "balance".to_uppercase().to_owned()
        } 

        if arg_exists("blockheight") {
            info = get(QueryType::BlockHeight, account);
            display = "blockheight".to_uppercase().to_owned()
        }

        if arg_exists("sync-delay") {
            info = get(QueryType::SyncDelay, account);
            display = "sync-delay".to_uppercase().to_owned()
        }
 
        if arg_exists("resources") {
            info = get(QueryType::Resources, account);
            display = "resources".to_uppercase().to_owned()
        }

        status_info!(display.to_uppercase(),format!("{}", info));
    }
}
