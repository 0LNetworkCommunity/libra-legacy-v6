//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use ol_types::config::TxType;
use crate::{entrypoint, submit_tx::{tx_params_wrapper, maybe_submit}};

/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValSetCmd {
    #[options(help = "add node to validator universe, i.e. make a candidate for validator set")]
    join: bool,
    #[options(help = "remove node from validator universe, i.e. cease being a candidate for validator set")]
    leave: bool,
    // #[options(help = "unjail the node, add to list, and remove jailed designation")]
    // unjail: bool,
}


impl Runnable for DemoCmd {    
    fn run(&self) {
        let entry_args = entrypoint::get_args();

        let tx_params = tx_params_wrapper(TxType::Cheap).unwrap();
        let script;
        if *&self.join {
          script = transaction_builder::encode_join_script();
        }

        if *&self.leave {
          script = transaction_builder::encode_leave_script();
        }


        maybe_submit(
          transaction_builder::encode_join_script(),
          // transaction_builder::encode_demo_e2e_script(42),
          &tx_params,
          entry_args.no_send,
          entry_args.save_path
        ).unwrap();
    }
}