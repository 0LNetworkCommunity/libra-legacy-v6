//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::application::app_config;
use abscissa_core::{Command, Options, Runnable};

use diem_genesis_tool::ol_node_files;

/// `node-files` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct NodeFilesCmd {
    #[options(help = "only make fullnode config files")]
    fullnode_only: bool,
}

impl Runnable for NodeFilesCmd {
    /// Print version message
    fn run(&self) {
        let cfg = app_config().to_owned();
        let home_dir = cfg.workspace.node_home.to_owned();
        // 0L convention is for the namespace of the operator to be appended by '-oper'
        let namespace = cfg.profile.account.clone().to_string().to_lowercase() + "-oper";
        let val_ip_address = cfg.profile.ip;

        match ol_node_files::make_node_yaml(
          home_dir.clone(),
          Some(val_ip_address),
          &namespace,
          self.fullnode_only,
        ) {
            Ok(_) => {
              println!("Node yaml files successfully written to: {:?}", home_dir)
            },
            Err(e) => {
              println!("ERROR: could not write node yaml files, message: {:?}", e.to_string())
            },
        }
    }
}
