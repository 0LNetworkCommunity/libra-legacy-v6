// `submit` subcommand



use abscissa_core::{Command, Options, Runnable};
use crate::prelude::*;
use libra_types::{waypoint::Waypoint, account_address::AccountAddress};
use libra_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    // test_utils::KeyPair,
};
use libra_crypto::test_utils;
use anyhow::Error;



use cli::{libra_client::LibraClient, AccountData};
use reqwest::Url;
use test_utils::KeyPair;

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

    let _height = 1u64;
    // // get an account height
    // let file = fs::File::open(format!("{:?}/block_{}.json", &miner_configs.get_block_dir(),height)).expect("Could not open block file");
    // let reader = BufReader::new(file);
    // let block: Block = serde_json::from_reader(reader).unwrap();

    let hex_literal = format!("0x{}", &miner_configs.profile.account);
    let account_address = AccountAddress::from_hex_literal(&hex_literal).unwrap();
    dbg!(&account_address);

    let url = miner_configs.chain_info.node.as_ref().unwrap().parse::<Url>();
    // let url: Result<Url, Error> = miner_configs.chain_info.node;
    let parsed_waypoint: Result<Waypoint, Error> = miner_configs.chain_info.base_waypoint.parse();
    
    //unwrap().parse::<Waypoint>();
    let auth_key = &miner_configs.profile.auth_key;
    dbg!(auth_key);
    let privkey = &miner_configs.profile.operator_private_key;
    // let operator_keypair = Some(AccountKeyPair::load(privkey));
    dbg!(privkey);

    // Create a client object

    let mut client = LibraClient::new(url.unwrap(), parsed_waypoint.unwrap()).unwrap();
    let account_state = client.get_account_state(account_address, true).unwrap();
    dbg!(&account_state);

    let mut sequence_number= 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }
    dbg!(&sequence_number);


    // // get a key key pair to use for signing transactions.
    //    let key_pair = KeyPair {
    //     /// the private key component
    //     private_key: privkey,
    //     /// the public key component
    //     public_key: Ed25519PublicKey.from(privkey),
    // };
    // dbg!(key_pair);


    // // get account_data struct
    // let sender_account_data = AccountData {
    //     account_address,
    //     authentication_key: auth_key,
    //     key_pair,
    //     sequence_number,
    //     status,
    // };

    // // Create the unsigned MinerState transaction script
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

    // // Submit the transaction with libra_client
    // client.submit_transaction(
    //     Some(&mut sender_account_data), 
    //     txn
    // )?;

    // TODO: Make synchronous.
    // if is_blocking {
    //     let sequence_number = self
    //         .get_account_resource_and_update(sender_address)?
    //         .sequence_number;
    //     self.wait_for_transaction(sender_address, sequence_number)?;
    // }
    Ok("Succcess".to_owned())
}
