//! `IpAddrUpdate` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;
use ol::{node::{client, node::Node}, config::AppCfg};
use ol_keys::{wallet, scheme::KeyScheme};
use ol_types::{config::TxType, account::ValConfigs};
use crate::{submit_tx::{TxError, TxParams, maybe_submit, tx_params_wrapper}, prelude::app_config};
use std::{process::exit, net::Ipv4Addr};

/// `IpAddrUpdate` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValConfigCmd {
    #[options(short = "v", help = "the validator's new ip address")]
    val_ip: Option<Ipv4Addr>,
    #[options(short = "f", help = "the fullnode of the validator's ip address")]
    fn_ip: Option<Ipv4Addr>,
    #[options(short = "g", help = "get the on-chain configs currently published")]
    get_on_chain: bool,

}

impl Runnable for ValConfigCmd {
    fn run(&self) {
        let cfg = app_config().clone();

        if *&self.get_on_chain {          
          get_val_configs(cfg.profile.account, cfg);
          return
        }
        // let _entry_args = entrypoint::get_args();
        let (_, _, w) = wallet::get_account_from_prompt();

        let val_cfg = ValConfigs::new(
          None, 
          KeyScheme::new(&w), 
          self.val_ip.expect("neeed a validator ip address"), 
          self.fn_ip.expect("neeed a fn ip address"), 
          None, 
          None
        );

        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

  
        match update_onchain_configs(
          &tx_params,
          val_cfg
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
pub fn update_onchain_configs(
  tx_params: &TxParams,
  val_cfg: ValConfigs,

) -> Result<TransactionView, TxError> {
  let script = transaction_builder::encode_register_validator_config_script_function(
      val_cfg.ow_human_name,
      val_cfg.op_consensus_pubkey,
      val_cfg.op_validator_network_addresses,
      val_cfg.op_fullnode_network_addresses,
  );

  maybe_submit(
    script,
    &tx_params,
    None // TODO: if people want to save tx for relaying elsewhere, unlikely.
  )
}

fn get_val_configs(account: AccountAddress, mut cfg: AppCfg) {
  
  // let account = 
  //   if args.account.is_some() { args.account.unwrap() }
  //   else { cfg.profile.account };
    
  let client = client::pick_client(
    None, &mut cfg
  ).unwrap_or_else(|e| {
    println!("ERROR: Cannot connect to a client. Message: {}", e);
    exit(1);
  });
  let mut node = Node::new(client, &cfg, false);

  if let Some(c) = node.get_validator_config( 
    account) {
      if let Some(cr)  = c.val.config {
        println!("validator configs");
        dbg!(&cr.consensus_pubkey);
      }
    }
}