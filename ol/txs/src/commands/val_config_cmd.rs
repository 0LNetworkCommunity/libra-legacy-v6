//! `IpAddrUpdate` subcommand

#![allow(clippy::never_loop)]

use crate::submit_tx::{maybe_submit, tx_params_wrapper, TxError};
use crate::tx_params::TxParams;
use abscissa_core::{Command, Options, Runnable};
use dialoguer::Confirm;
use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use ol_keys::{scheme::KeyScheme, wallet};
use ol_types::{account::ValConfigs, config::TxType};
use std::{net::Ipv4Addr, process::exit};

/// `IpAddrUpdate` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValConfigCmd {
    #[options(short = "v", help = "the validator's new ip address")]
    val_ip: Option<Ipv4Addr>,
    #[options(short = "f", help = "the fullnode of the validator's ip address")]
    vfn_ip: Option<Ipv4Addr>,
}

impl Runnable for ValConfigCmd {
    fn run(&self) {
        println!("You will be asked to confirm the tx after viewing the new configurations.");

        if self.val_ip.is_none() || self.vfn_ip.is_none() {
            println!("You must provide IP addresses for --val-ip and --vfn-ip, exiting.");
            exit(1);
        }
        // let _entry_args = entrypoint::get_args();
        let (_, _, w) = wallet::get_account_from_prompt();

        let val_cfg = ValConfigs::new(
            None,
            KeyScheme::new(&w),
            self.val_ip.expect("neeed a validator ip address"),
            self.vfn_ip.expect("neeed a fn ip address"),
            None,
            None,
        );

        let txt = format!(
            "New consensus pubkey: {} \n 
        New validator network addresses: {}, \n
        New vfn fullnode network addresses: {}",
            hex::encode(&val_cfg.op_consensus_pubkey),
            val_cfg.op_val_net_addr_for_vals.to_string(),
            val_cfg.op_vfn_net_addr_for_public.to_string(),
        );

        println!("{}", &txt);

        match Confirm::new().with_prompt("\nDo you want to submit a TX to update your on-chain configs? Warning: malformed keys and addresses may make your node drop out of consensus.").interact().unwrap() {
      true => {},
      _ =>  {
        print!("Validator configuration aborted.");
        exit(1);
      }
    }

        let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

        match update_onchain_configs(&tx_params, val_cfg) {
            Ok(r) => {
                println!("{:?}", &r);
            }
            Err(e) => {
                println!("ERROR: could not update on-chain ip address: {:?}", &e);
                exit(1);
            }
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
        script, &tx_params,
        None, // TODO: if people want to save tx for relaying elsewhere, unlikely.
    )
}
