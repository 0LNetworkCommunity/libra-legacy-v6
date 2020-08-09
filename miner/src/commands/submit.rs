// `submit` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{block::Block, prelude::*};
use libra_types::{waypoint::Waypoint, account_address::AccountAddress, transaction::authenticator::AuthenticationKey};
use libra_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey, Ed25519Signature},
    test_utils::KeyPair,
    PrivateKey,
};
// use libra_crypto::test_utils::KeyPair;
use anyhow::Error;
// use client::{
//     account::{Account, AccountData, AccountTypeSpecifier},
//     keygen::KeyGen,
// };
use cli::{libra_client::LibraClient, AccountData, AccountStatus};
use reqwest::Url;
use std::path::PathBuf;
use libra_config::config::NodeConfig;
use libra_types::transaction::{Script, TransactionArgument, TransactionPayload};
use libra_types::transaction::helpers::*;
use crate::delay::delay_difficulty;
use stdlib::transaction_scripts;

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
        submit_test(self.path.clone(), self.height.clone());
    }

}

fn submit_test(mut config_path: PathBuf, height_to_submit: usize ) -> Result<String, Error> {
    let miner_configs = app_config();
    let mut tower_height: usize = 1;

    // TODO (LG): get the block info.
    // let file = fs::File::open(format!("{:?}/block_{}.json", &miner_configs.get_block_dir(), height_to_submit)).expect("Could not open block file");
    // let reader = BufReader::new(file);
    // let block: Block = serde_json::from_reader(reader).unwrap();
    // let challenge = block.preimage;
    // let proof = block.data;

    let challenge = "aa".as_bytes().to_vec();
    let proof = "37485738".as_bytes().to_vec();

    config_path.push("0/node.config.toml");

    let config = NodeConfig::load(&config_path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", config_path));
    match &config.test {
        Some( conf) => {
            println!("Swarm Keys : {:?}", conf);
            tower_height = 0;
        },
        None =>{
            println!("test config does not set.");
        }
    }
    
    // TODO (LG): When we are not testing swarm.
    // let mut is_prod = true;
    // if is_prod {
    //     let hex_literal = format!("0x{}", &miner_configs.profile.account);
    //     let account_address = AccountAddress::from_hex_literal(&hex_literal).unwrap();
    //     dbg!(&account_address);
        
    //     let url = miner_configs.chain_info.node.as_ref().unwrap().parse::<Url>();
    //     // let url: Result<Url, Error> = miner_configs.chain_info.node;
    //     let parsed_waypoint: Result<Waypoint, Error> = miner_configs.chain_info.base_waypoint.parse();
        
    //     //unwrap().parse::<Waypoint>();
    //     let auth_key = &miner_configs.profile.auth_key;
    //     dbg!(auth_key);
    //     let privkey = &miner_configs.profile.operator_private_key;
    //     tower_height = height_to_submit;
    //     // let operator_keypair = Some(AccountKeyPair::load(privkey));
    //     dbg!(privkey);
    // }
    

    // Create a client object
    let mut client = LibraClient::new(
        Url::parse(format!("http://localhost:{}", config.rpc.address.port()).as_str()).unwrap(),
        config.base.waypoint.waypoint_from_config().unwrap().clone()
    ).unwrap();

    
    let mut private_key = config.test.unwrap().operator_keypair.unwrap();
    let auth_key = AuthenticationKey::ed25519(&private_key.public_key());

    let address = auth_key.derived_address();
    let account_state = client.get_account_state(address.clone(), true).unwrap();
    dbg!(&account_state);


    let mut sequence_number = 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }
    dbg!(&sequence_number);

    // Create the unsigned MinerState transaction script
    let script = Script::new(
        transaction_scripts::StdlibScript::Redeem.compiled_bytes().into_vec(),
        vec![],
        vec![
            TransactionArgument::U8Vector(challenge),
            TransactionArgument::U64(delay_difficulty()),
            TransactionArgument::U8Vector(proof),
            TransactionArgument::U64(tower_height as u64),
        ],
    );


    // Plz Halp (ZM):
    // sign the transaction script
    let txn = create_user_txn(
        &KeyPair::from(private_key.take_private().clone().unwrap()),
        TransactionPayload::Script(script),
        address,
        sequence_number,
        0,
        0,
        "GAS".parse()?,
        50000, // for compatibility with UTC's timestamp.
    )?;

    // Plz Halp  (ZM):
    // get account_data struct
    let mut sender_account_data = AccountData {
        address,
        authentication_key: Some(auth_key.to_vec()),
        key_pair: Some(KeyPair::from(private_key.take_private().unwrap())),
        sequence_number,
        status: AccountStatus::Persisted,
    };

    // Plz Halp (ZM):
    // // Submit the transaction with libra_client
    client.submit_transaction(
        Some(&mut sender_account_data),
        txn
    )?;

    // TODO (LG): Make synchronous to libra client.
    // if is_blocking {
    //     let sequence_number = self
    //         .get_account_resource_and_update(sender_address)?
    //         .sequence_number;
    //     self.wait_for_transaction(sender_address, sequence_number)?;
    // }
    Ok("Succcess".to_owned())
}
