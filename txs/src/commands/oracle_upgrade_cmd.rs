//! `OracleUpgrade` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use crate::{prelude::app_config, submit_tx::{
    submit_tx, get_tx_params, eval_tx_status
}};
use libra_types::{transaction::{Script}};
use std::{fs, io::prelude::*, path::PathBuf};

/// `OracleUpgrade` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct OracleUpgradeCmd {
    #[options(short = "f", help = "Path of upgrade file")]
    upgrade_file_path: Option<PathBuf>,
}

pub fn oracle_tx_script(upgrade_file_path: &PathBuf) -> Script {
    let mut file = fs::File::open(upgrade_file_path)
        .expect("file should open read only");
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer).expect("failed to read the file");

    let id = 1; // upgrade is oracle #1
    transaction_builder::encode_ol_oracle_tx_script(id, buffer)
}

impl Runnable for OracleUpgradeCmd {
    fn run(&self) {                
        let tx_params = get_tx_params().unwrap();

        let path = if *&self.upgrade_file_path.is_some() {
            self.upgrade_file_path.clone().unwrap() 
        } else {
            let cfg = app_config();
            cfg.workspace.stdlib_bin_path.clone()
        };

        match submit_tx(
            &tx_params, 
            oracle_tx_script(&path)
        ) {
            Err(err) => { println!("{:?}", err) }
            Ok(res)  => {
                eval_tx_status(res);
            }
        }

    }
}
