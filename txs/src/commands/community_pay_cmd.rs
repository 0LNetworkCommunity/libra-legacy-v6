//! `community-pay` subcommand

#![allow(clippy::never_loop)]

use crate::{
    entrypoint,
    submit_tx::{maybe_submit, tx_params_wrapper, TxError},
};
use abscissa_core::{Command, Options, Runnable};

use diem_json_rpc_types::views::TransactionView;
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::account_address::AccountAddress;
use ol_types::config::TxType;
use std::{path::PathBuf, process::exit};

#[derive(Command, Debug, Default, Options)]

/// create a community wallet payment/transfer proposal
pub struct CommunityPayCmd {
    #[options(short = "a", help = "the new user's address")]
    destination_account: String,
    #[options(short = "c", help = "the amount of coins to send to new user")]
    coins: u64,
    #[options(short = "m", help = "string, text of memo to accompany payment")]
    memo: String,
}

impl Runnable for CommunityPayCmd {
    fn run(&self) {
        let entry_args = entrypoint::get_args();
        let destination = match self.destination_account.parse::<AccountAddress>() {
            Ok(a) => a,
            Err(e) => {
                println!(
                    "ERROR: could not parse this account address: {}, message: {}",
                    self.destination_account,
                    &e.to_string()
                );
                exit(1);
            }
        };

        match community_payment_proposal(
            destination,
            self.coins.clone(),
            self.memo.clone(),
            entry_args.save_path,
        ) {
            Ok(_) => println!(
                "Success: community payment proposed for 3 epochs(days) from now: {}",
                self.destination_account
            ),
            Err(e) => {
                println!("ERROR: could not create community transfer proposal:");
                if let Some(loc) = &e.location {
                    if loc.contains("TransferScripts") {
                        match e.abort_code {
                            Some(0) => println!("this account is not a community wallet\n"),
                            Some(1) => println!("destination account is not a slow wallet\n"),
                            _ => println!("misc error, could not propose the tx: {:?}\n", &e),
                        }
                    } else {
                        println!("misc error, could not propose the tx: {:?}\n", &e)
                    }
                };

                exit(1);
            }
        }
    }
}

/// create an account by sending coin to it
pub fn community_payment_proposal(
    destination: AccountAddress,
    coins: u64,
    memo: String,
    save_path: Option<PathBuf>,
) -> Result<TransactionView, TxError> {
    let tx_params = tx_params_wrapper(TxType::Mgmt).unwrap();

    // NOTE: coins here do not have the scaling factor. Rescaling is the responsibility of the Move script. See the script in ol_accounts.move for detail.
    let script = transaction_builder::encode_community_transfer_script_function(
        destination,
        coins,
        memo.as_bytes().to_vec(),
    );

    maybe_submit(script, &tx_params, save_path)
}
