//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{
    client::make_client,
    application::app_config,
    metadata::Metadata
};
use reqwest::Url;
use libra_types::{waypoint::Waypoint};
use std::{env};

/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Default, Options)]
pub struct CompareCmd {
    #[options(short = "u", help = "URL for client connection")]
    url: Option<Url>,

    #[options(short = "w", help = "Waypoint to sync from")]
    waypoint: Option<Waypoint>,

    // #[options(short = "a", help = "account to query")]
    // account: String,
}

impl Runnable for CompareCmd {
    fn run(&self) {
        let config = app_config();
        let local_url = config.upstream_node_url.clone();
        let remote_url = config.upstream_node_url.clone();
        let waypoint = self.waypoint.clone().unwrap();

        let local = Metadata::new(
            local_url.clone(),
            make_client(
                Some(local_url), 
                waypoint
            ).unwrap()
        ).unwrap();

        let remote = Metadata::new(
            remote_url.clone(),
            make_client(
               Some(remote_url), 
                waypoint
            ).unwrap()
        ).unwrap();

        Metadata::compare(local, remote);
        // for u in urls.iter() {
        //     Metadata::new(url.unwrap, client);
        //     meta_vec(meta_vec)
        //     // let block_metadata = client
        //     // .get_metadata()
        //     // .unwrap_or_else(|e| {
        //     //     panic!(
        //     //         "Not able to connect to validator at {:#?}. Error: {}",
        //     //         u,
        //     //         e,
        //     //     )
        //     // });

        //     // let ledger_info_str = format!(
        //     //     "latest height: {} URL: {:#?} timestamp: {}",
        //     //     block_metadata.version,
        //     //     u.as_ref().unwrap(),
        //     //     DateTime::<Utc>::from(UNIX_EPOCH + Duration::from_micros(block_metadata.timestamp))
        //     // );
            
        //     // println!("{:#?}", ledger_info_str);
        // }
    }
}
