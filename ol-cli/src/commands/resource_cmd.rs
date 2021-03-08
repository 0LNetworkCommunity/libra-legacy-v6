//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::client::make_client;
use reqwest::Url;
use libra_types::{account_address::AccountAddress, waypoint::Waypoint};
// use num_format::{Locale, ToFormattedString};

use crate::account_resource::get_annotate_account_blob;
/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Default, Options)]
pub struct ResourceCmd {
    #[options(short = "u", help = "URL for client connection")]
    url: Option<Url>,

    #[options(short = "w", help = "Waypoint to sync from")]
    waypoint: Option<Waypoint>,

    #[options(short = "a", help = "account to query")]
    account: String,
}

impl Runnable for ResourceCmd {
    fn run(&self) {
        let client = make_client(self.url.clone(), self.waypoint.clone().unwrap()).unwrap();
        let account = self.account.clone().parse::<AccountAddress>().unwrap();
        let resources = get_annotate_account_blob(client, account);

        println!("{:?}", resources.unwrap().0);
    }
}
