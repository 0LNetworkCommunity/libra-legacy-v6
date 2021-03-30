//! `init` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use crate::{config::AppConfig};
use std::{path::PathBuf};

/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    #[options(help = "path to save app's config into txs.toml")]
    path: Option<PathBuf>,
}

impl Runnable for InitCmd {
    /// Run
    fn run(&self) {
        // AppConfig::init_app_configs(self.path.clone());
    }
}
