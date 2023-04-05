//! `val-set` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper},
};
use abscissa_core::{Command, Options, Runnable};
use diem_logger::error;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;
use ol_types::config::TxType;
use std::{process::exit, ops::Mul};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValSetCmd {
    #[options(
        short = "b",
        help = "update bid in Proof of Fee auction."
    )]
    bid: Option<f64>,
    #[options(
        short = "e",
        help = "Expiration for bid in Proof of Fee auction."
    )]
    expiry: u64,
    #[options(
        short = "r",
        help = "Retract bid. Can only be done once per epoch."
    )]
    retract: bool,

    #[options(
        short = "j",
        help = "mark a vouchee validator as unjailed. Validators can't unjail self."
    )]
    unjail: Option<AccountAddress>,


}

impl Runnable for ValSetCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();
        
        let script = if let Some(addr) = *&self.unjail {
            transaction_builder::encode_voucher_unjail_script_function(addr)
        } else if self.retract {
            transaction_builder::encode_pof_retract_bid_script_function()
        } else if self.bid.is_some() && self.expiry > 0 {
            let bid = *&self.bid.unwrap();
            let scaled_bid_move = (bid.mul(10_f64)) as u64;
            transaction_builder::encode_pof_update_bid_script_function(
                scaled_bid_move,
                *&self.expiry,
            )
        } else {
            error!("Invalid arguments for val-set command. Did you want to make a bid, or unjail a validator?");
            exit(1);
        };

        match maybe_submit(
            script,
            // transaction_builder::encode_demo_e2e_script(42),
            &tx_params,
            entry_args.save_path,
        ) {
            Err(e) => {
                println!(
                    "ERROR: could not submit validator-set transaction, message: \n{:?}",
                    &e
                );
                exit(1);
            }
            _ => {
                println!("SUCCESS: unjail transaction submitted");
            }
        }
    }
}
