//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::client::make_client;
use reqwest::Url;
use libra_types::{account_address::AccountAddress, waypoint::Waypoint};
use num_format::{Locale, ToFormattedString};


/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Default, Options)]
pub struct BalCmd {
    #[options(short = "u", help = "URL for client connection")]
    url: Option<Url>,

    #[options(short = "w", help = "Waypoint to sync from")]
    waypoint: Option<Waypoint>,

    #[options(short = "a", help = "account to query")]
    account: String,
}

impl Runnable for BalCmd {
    fn run(&self) {
        let mut client = make_client(self.url.clone(), self.waypoint.clone().unwrap()).unwrap();

        let account_struct = self.account.clone().parse::<AccountAddress>().unwrap();
        let (account_view, _) = client.get_account(account_struct, true).unwrap();

        for av in account_view.unwrap().balances.iter() {
            if av.currency == "GAS" { println!("{} GAS", av.amount.to_formatted_string(&Locale::en)) }
        }
    }
}
