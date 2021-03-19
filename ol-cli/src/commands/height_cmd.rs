//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::check;
use reqwest::Url;
use libra_types::{waypoint::Waypoint};
use chrono::{
    prelude::{Utc},
    DateTime,
};
use std::{env,time::{Duration, UNIX_EPOCH}};

/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Default, Options)]
pub struct HeightCmd {
    #[options(short = "u", help = "URL for client connection")]
    url: Option<Url>,

    #[options(short = "w", help = "Waypoint to sync from")]
    waypoint: Option<Waypoint>,
}

impl Runnable for HeightCmd {
    fn run(&self) {
        let mut check = check::Check::new();
        dbg!(&check.chain_height());
        // let mut client = make_client(self.url.clone(), self.waypoint.clone().unwrap()).unwrap();
        
        // let block_metadata = client
        // .get_metadata()
        // .unwrap_or_else(|e| {
        //     panic!(
        //         "Not able to connect to validator at {:#?}. Error: {}",
        //         &self.url,
        //         e,
        //     )
        // });

        // let ledger_info_str = format!(
        //     "latest height: {} timestamp: {}",
        //     block_metadata.version,
        //     DateTime::<Utc>::from(UNIX_EPOCH + Duration::from_micros(block_metadata.timestamp))
        // );

        // println!("{:#?}", ledger_info_str);
    }
}
