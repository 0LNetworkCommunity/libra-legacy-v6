// `submit` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::prelude::*;
use libra_types::{waypoint::Waypoint, account_address::AccountAddress};
use libra_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey, Ed25519Signature},
    test_utils::KeyPair,
    PrivateKey,
};
use libra_crypto::test_utils;
use anyhow::Error;
use language_e2e_tests::{
    account::{Account, AccountData, AccountTypeSpecifier},
    keygen::KeyGen,
};
use cli::{libra_client::LibraClient, AccountData};
use reqwest::Url;
use std::path::PathBuf;
use libra_config::config::NodeConfig;
use libra_types::transaction::{Script, TransactionArgument, TransactionPayload};
use libra_types::transaction::helpers::*;

#[derive(Command, Debug, Default, Options)]
pub struct SubmitCmd {
    #[options(help = "Provide a waypoint for the libra chain")]
    waypoint: String, //Option<Waypoint>,

    #[options(help = "Path of swarm config directory.")]
    path: PathBuf,

    #[options(help = "Already mined height to submit")]
    height: usize,
}

impl Runnable for SubmitCmd {
    fn run(&self) {
        println!("TESTING SUBMITTING WITH KEYPAIR TO SWARM");
        submit_test(self.path.clone());
    }

}

fn submit_test(mut config_path: PathBuf ) -> Result<String, Error> {
    let miner_configs = app_config();

    let _height = 1u64;
    // // get an account height
    // let file = fs::File::open(format!("{:?}/block_{}.json", &miner_configs.get_block_dir(),height)).expect("Could not open block file");
    // let reader = BufReader::new(file);
    // let block: Block = serde_json::from_reader(reader).unwrap();

    // let hex_literal = format!("0x{}", &miner_configs.profile.account);
    // let account_address = AccountAddress::from_hex_literal(&hex_literal).unwrap();
    // dbg!(&account_address);
    //
    // let url = miner_configs.chain_info.node.as_ref().unwrap().parse::<Url>();
    // // let url: Result<Url, Error> = miner_configs.chain_info.node;
    // let parsed_waypoint: Result<Waypoint, Error> = miner_configs.chain_info.base_waypoint.parse();
    //
    // //unwrap().parse::<Waypoint>();
    // let auth_key = &miner_configs.profile.auth_key;
    // dbg!(auth_key);
    // let privkey = &miner_configs.profile.operator_private_key;
    // // let operator_keypair = Some(AccountKeyPair::load(privkey));
    // dbg!(privkey);

    config_path.push("0/node.config.toml");

    let config = NodeConfig::load(&config_path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", config_path));
    match &config.test {
        Some( conf) => {
            println!("Swarm Keys : {:?}", conf);
        },
        None =>{
            println!("test config does not set.");
        }
    }

    // Create a client object

    let mut client = LibraClient::new(
        Url::parse(format!("http://localhost:{}", config.rpc.address.port()).as_str()).unwrap(),
        config.base.waypoint.waypoint_from_config().unwrap().clone()
    ).unwrap();
    let auth_key = config.test.unwrap().auth_key.unwrap();
    let address = auth_key.derived_address();
    let account_state = client.get_account_state(address.clone(), true).unwrap();
    dbg!(&account_state);

    let private_key = config.test.unwrap().operator_keypair.unwrap();

    let mut sequence_number = 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }
    dbg!(&sequence_number);

    // get account_data struct
    // let sender_account_data = AccountData {
    //     address,
    //     authentication_key: Some(auth_key.to_vec()),
    //     key_pair: Some(KeyPair{private_key: operator_key.take_private(), public_key: operator_key.public_key()))},
    //     sequence_number,
    //     status,
    // };

    // Create the unsigned MinerState transaction script
    let script = Script::new(
        StdlibScript::Redeem.compiled_bytes().into_vec(),
        vec![],
        vec![
            TransactionArgument::U8Vector(challenge),
            TransactionArgument::U64(difficulty),
            TransactionArgument::U8Vector(proof),
            TransactionArgument::U64(tower_height),
        ],
    );


    let keypair = KeyPair::from(private_key );
    let signer: Box<&dyn TransactionSigner> = Box::new(&keypair);
    // sign the transaction script
    let txn = create_user_txn(
        signer,
        TransactionPayload::Script(script),
        address,
        sequence_number,
        0,
        0,
        "GAS".parse()?,
        50000, // for compatibility with UTC's timestamp.
    )?;

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
