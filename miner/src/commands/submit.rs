// `submit` subcommand



use abscissa_core::{Command, Options, Runnable};
use crate::prelude::*;
use libra_types::{transaction::{TransactionArgument, helpers::create_user_txn, TransactionPayload}, waypoint::Waypoint, account_address::AccountAddress};
use rustyline::error::ReadlineError;
use rustyline::Editor;
use crate::{submit_tx, block::*, delay::delay_difficulty};
use anyhow::Error;
use std::fs;
use std::io::BufReader;
use std::path::Path;
use cli::{libra_client::LibraClient, AccountData};
use reqwest::Url;

#[derive(Command, Debug, Default, Options)]
pub struct SubmitCmd {
    #[options(help = "Provide a waypoint for the libra chain")]
    waypoint: String, //Option<Waypoint>,

    #[options(help = "Already mined height to submit")]
    height: usize,
}

impl Runnable for SubmitCmd {
    fn run(&self) {
        println!("TESTING SUBMITTING WITH KEYPAIR TO SWARM");
        submit_test();
    }

}

fn submit_test () -> Result<String,Error>{
    let miner_configs = app_config();

    let height = 1u64;
    // let file = fs::File::open(format!("{:?}/block_{}.json", &miner_configs.get_block_dir(),height)).expect("Could not open block file");
    // let reader = BufReader::new(file);
    // let block: Block = serde_json::from_reader(reader).unwrap();
    let hex_literal = format!("0x{}", &miner_configs.profile.account);
    let account_address = AccountAddress::from_hex_literal(&hex_literal).unwrap();
    dbg!(&account_address);

    let url= miner_configs.chain_info.node.as_ref().unwrap().parse::<Url>();
    // let url: Result<Url, Error> = miner_configs.chain_info.node;
    let parsed_waypoint: Result<Waypoint, Error> = miner_configs.chain_info.base_waypoint.parse();
    
    //unwrap().parse::<Waypoint>();

    let mut client = LibraClient::new(url.unwrap(), parsed_waypoint.unwrap()).unwrap();
    let account_state = client.get_account_state(account_address, true).unwrap();
    dbg!(&account_state);

    let mut sequence_number= 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }

    dbg!(&sequence_number);

    // let sender_account_data = AccountData {
    //     account_address,
    //     authentication_key: miner_configs.profile.auth_key,
    //     key_pair: miner_configs.profile.private_key,
    //     sequence_number,
    //     status,
    // };

    // // create the MinerState transaction script
    // let script = Script::new(
    //     StdlibScript::Redeem.compiled_bytes().into_vec(),
    //     vec![],
    //     vec![
    //         TransactionArgument::U8Vector(challenge),
    //         TransactionArgument::U64(difficulty),
    //         TransactionArgument::U8Vector(proof),
    //         TransactionArgument::U64(tower_height),
            
    //     ],
    // );

    // // sign the transaction script
    // let txn = create_user_txn(
    //     txn_expiration,
    //     signer,
    //     payload,
    //     sender_address,
    //     sender_sequence_number,
    //     max_gas_amount,
    //     gas_unit_price,
    //     gas_currency_code, // for compatibility with UTC's timestamp.
    // )?;

    // // Submit the transaction with the client proxy
    // // let sender_account = self.accounts.get_mut(sender_ref_id);
    // LibraClient::submit_transaction(
    //     Some(&mut sender_account_data), 
    //     txn
    // )?;

    // TODO: This was making the client fail.
    // if is_blocking {
    //     let sequence_number = self
    //         .get_account_resource_and_update(sender_address)?
    //         .sequence_number;
    //     self.wait_for_transaction(sender_address, sequence_number)?;
    // }
    Ok("Succcess".to_owned())
}
// impl Runnable for SubmitCmd {
//     fn run(&self) {
//         let miner_configs = app_config();

//         let mut rl = Editor::<()>::new();

//         println!("Enter your 0L mnemonic");

//         let readline = rl.readline(">> ");


//         match readline {
//             Ok(line) => {
//                 println!("Mnemonic: \n{}", line);

//                 let waypoint: Waypoint;
//                 let parsed_waypoint: Result<Waypoint, Error> = self.waypoint.parse();
//                 match parsed_waypoint {
//                     Ok(v) => {
//                         println!("Using Waypoint from CLI args:\n{}", v);
//                         waypoint = parsed_waypoint.unwrap();
//                     }
//                     Err(_e) => {
//                         println!("Error: Waypoint cannot be parsed from command line args. Received: {:?}\nDid you pass --waypoint=0:<hash>? \n WILL FALLBACK TO WAYPOINT FROM miner.toml\n {:?}",
//                         self.waypoint,
//                         miner_configs.chain_info.base_waypoint);
//                         waypoint = miner_configs.chain_info.base_waypoint.parse().unwrap();

//                     }
//                 }

//                 let result = build_block::submit_block(
//                     &miner_configs,
//                     line,
//                     waypoint,
//                     self.height);
//                 match result {
//                     Ok(_val) => { }
//                     Err(_) => {
//                         println!("Failed to submit block");
//                     }
//                 }
//             }
//             Err(ReadlineError::Interrupted) => {
//                 println!("CTRL-C");
//             }
//             Err(ReadlineError::Eof) => {
//                 println!("CTRL-D");
//             }
//             Err(err) => {
//                 println!("Error: {:?}", err);
//             }
//         }

//     }
// }
