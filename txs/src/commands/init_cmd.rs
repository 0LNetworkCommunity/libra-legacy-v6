//! `init` subcommand

#![allow(clippy::never_loop)]

use std::{path::PathBuf};
use crate::{config::AppConfig};
use abscissa_core::{Command, Options, Runnable};

/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    #[options(help = "path to save app's config into txs.toml")]
    path: Option<PathBuf>,
}

impl Runnable for InitCmd {
    /// Run
    fn run(&self) {
        AppConfig::init_app_configs(self.path.clone());
    }
}
