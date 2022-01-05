//! `IpAddrUpdate` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use ol_types::config::TxType;
use crate::{entrypoint, submit_tx::{TxError, TxParams, maybe_submit, tx_params_wrapper}};
use std::process::exit;
use std::path::PathBuf;


/// `IpAddrUpdate` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct IpAddrUpdateCmd {
    #[options(short = "i", help = "the validator's new ip address")]
    ipaddr: String,
}

impl Runnable for IpAddrUpdateCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();

        match update_ipaddr(
          &tx_params,
          entry_args.save_path
        ) {
            Ok(r) => {
              println!("{:?}", &r);
            },
            Err(e) => {
              println!("ERROR: could not update on-chain ip address: {:?}", &e);
              exit(1);
            },
        }
    }
}

/// perform tx to update validator's registered ip address on-chain
pub fn update_ipaddr(
  tx_params: &TxParams, save_path: Option<PathBuf>
) -> Result<TransactionView, TxError> {
  let script = transaction_builder::encode_register_validator_config_script_function(
      // validator_operator_account
      // validator_account
      // consensus_pubkey
      // validator_network_addresses
      // fullnode_network_addresses
  );

  maybe_submit(
    script,
    &tx_params,
    save_path
  )
}
