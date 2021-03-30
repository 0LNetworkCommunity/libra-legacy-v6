//! `CreateAccount` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use cli::libra_client::LibraClient;
use crate::{submit_tx::{TxParams, eval_tx_status, get_tx_params, submit_tx}};
use libra_types::{account_address::AccountAddress, account_state::AccountState, transaction::{Script}};
use std::{fs, path::PathBuf};
use std::convert::TryFrom;
/// `CreateAccount` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct AutopayNewCmd {
    #[options(help = "path of account.json")]
    account_json_path: PathBuf,
}

// pub fn create_user_account_script(account_json_path: &str) -> Script {
//     // get epoch height

//         //     let (blob, _version) = self
//         //     .client
//         //     .get_account_state_blob(AccountAddress::ZERO)
//         //     .unwrap();
//         // let mut cs = ChainState::default();
//         // if let Some(account_blob) = blob {
//         //     let account_state = AccountState::try_from(&account_blob).unwrap();
//         //     let meta = self.client.get_metadata().unwrap();
//         //     cs.epoch = account_state
//         //         .get_configuration_resource()
//         //         .unwrap()
//         //         .unwrap()
//         //         .epoch();

//     // open json
//     // iterate through

//     let file = fs::File::open(account_json_path)
//         .expect("file should open read only");
//     let json: serde_json::Value = serde_json::from_reader(file)
//         .expect("file should be proper JSON");
//     let block = json.get("block_zero")
//         .expect("file should have block_zero and preimage key");

//     let preimage = block
//         .as_object().unwrap()
//         .get("preimage").unwrap()
//         .as_str().unwrap();
    
//     let pre_hex = hex::decode(preimage).unwrap();

//     let proof = block
//         .as_object().unwrap()
//         .get("proof").unwrap()
//         .as_str().unwrap();
    
//     let proof_hex = hex::decode(proof).unwrap();
//     transaction_builder::encode_create_user_account_script(pre_hex, proof_hex)
// }

fn get_epoch(tx_params: TxParams){
            // Get epoch
        let mut client = LibraClient::new(
            tx_params.url.clone(), tx_params.waypoint
        ).unwrap();
        let (blob, _version) = client
        .get_account_state_blob(AccountAddress::ZERO)
        .unwrap();

        // dbg!(&blob);
        // let mut cs = ChainState::default();
        if let Some(account_blob) = blob {
            let account_state = AccountState::try_from(&account_blob).unwrap();
            // let meta = client.get_metadata().unwrap();
            let epoch = account_state
                .get_configuration_resource()
                .unwrap()
                .unwrap()
                .epoch();
            
            dbg!(epoch);
        }

}

impl Runnable for AutopayNewCmd {   
    fn run(&self) {
        let tx_params = get_tx_params().unwrap();
        get_epoch(tx_params)
    //     let account_json = self.account_json_path.to_str().unwrap();



    //     match submit_tx(
    //         &tx_params, 
    //         create_user_account_script(account_json)
    //     ) {
    //         Err(err) => { println!("{:?}", err) }
    //         Ok(res)  => {
    //             eval_tx_status(res);
    //         }
    //     }
    }
}