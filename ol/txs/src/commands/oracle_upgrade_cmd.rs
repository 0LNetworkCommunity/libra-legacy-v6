//! `oracle-upgrade` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    prelude::app_config,
    submit_tx::{maybe_submit, tx_params_wrapper},
};
use abscissa_core::{Command, Options, Runnable};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::{account_address::AccountAddress, transaction::TransactionPayload};
use ol_types::config::TxType;
use std::{fs, io::prelude::*, path::PathBuf, process::exit};

/// `OracleUpgrade` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct OracleUpgradeCmd {
    #[options(short = "v", help = "Do the vote tx")]
    vote: bool,
    #[options(short = "f", help = "Path of upgrade file")]
    upgrade_file_path: Option<PathBuf>,
    #[options(short = "h", help = "Use hash instead of binary")]
    hash: Option<String>,
    #[options(short = "d", help = "Delegate voting power to another validator")]
    delegate: Option<AccountAddress>,
    #[options(short = "e", help = "Enable delegation")]
    enable_delegation: bool,
    #[options(short = "r", help = "Remove delegation")]
    remove_delegation: bool,
}

impl Runnable for OracleUpgradeCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Critical).unwrap();

        let script = if self.vote {
            if let Some(hex_hash) = &self.hash {
                let bytes = hex::decode(hex_hash).expect("Input must be a hex string");
                oracle_hash_tx_script(bytes)
            } else {
                let path = self.upgrade_file_path.clone().unwrap_or_else(|| {
                    let cfg = app_config();
                    match cfg.workspace.stdlib_bin_path.clone() {
                        Some(p) => p,
                        None => {
                            println!(
                    "could not find path to compiled stdlib.mv, was this set in 0L.toml? \
                    Alternatively pass the full path with: \
                    -f <project_root>/language/diem-framework/staged/stdlib.mv"
                  );
                            exit(1);
                        }
                    }
                });

                oracle_tx_script(&path)
            }
        } else if self.enable_delegation {
            transaction_builder::encode_ol_enable_delegation_script_function()
        } else if self.remove_delegation {
            transaction_builder::encode_ol_remove_delegation_script_function()
        } else if let Some(destination) = self.delegate {
            transaction_builder::encode_ol_delegate_vote_script_function(destination)
        } else {
            println!("Nothing to do from command line args. Did you mean to pass --vote?");
            exit(1);
        };

        match maybe_submit(script, &tx_params, entry_args.save_path) {
            Err(e) => {
                println!(
                    "ERROR: could not submit oracle transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
            _ => {}
        }
    }
}

pub fn oracle_tx_script(upgrade_file_path: &PathBuf) -> TransactionPayload {
    let mut file = fs::File::open(upgrade_file_path).expect("file should open read only");
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer)
        .expect("failed to read the file");

    let id = 1; // upgrade is oracle #1
    transaction_builder::encode_ol_oracle_tx_script_function(id, buffer)
}

pub fn oracle_hash_tx_script(upgrade_hash: Vec<u8>) -> TransactionPayload {
    let id = 2; // upgrade with hash is oracle #2
    transaction_builder::encode_ol_oracle_tx_script_function(id, upgrade_hash)
}
