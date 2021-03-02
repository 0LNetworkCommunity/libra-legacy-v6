//! `version` subcommand

#![allow(clippy::never_loop)]

use std::{path::PathBuf};
use crate::{config::AppConfig};
use abscissa_core::{Command, Options, Runnable};


/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    #[options(help = "path of account.json")]
    path: Option<PathBuf>,
}


impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        let (authkey, account, _) = keygen::account_from_prompt();
        AppConfig::init_app_configs(authkey, account, self.path.clone());
    }
}
