//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{
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

}

impl Runnable for CompareCmd {
    fn run(&self) {
        Metadata::compare_from_config();
    }
}
