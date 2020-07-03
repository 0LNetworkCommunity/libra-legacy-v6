//! OlMiner submit_tx module
#![forbid(unsafe_code)]

use crate::error::{Error, ErrorKind};
use cli::client_proxy::ClientProxy;
use libra_types::{account_address::AccountAddress, waypoint::Waypoint};

// use crate::application::{MINER_MNEMONIC, DEFAULT_PORT};
const DEFAULT_PORT: u64 = 2344; // TODO: this will likely deprecated in favor of urls and discovery.
                                // const DEFAULT_NODE: &str = "src/config/test_data/single.node.config.toml";
const ASSOCIATION_KEY_FILE: &str = "../0_dev_config/mint.key"; // Empty String or invalid file get converted to a None type in the constructor.

pub fn submit_vdf_proof_tx_to_network(
    challenge: Vec<u8>,
    difficulty: u64,
    proof: Vec<u8>,
    waypoint: Waypoint,
    mnemonic_string: String,
    node: String,
) -> Result<(), Error> {
    //! Functions for submitting proofs on chain

    // TODO (ZM): I think this can generate a number of configs including Waypoint.
    // let mut swarm_configs = NodeConfig::load(DEFAULT_NODE).expect("Unable to load config");
    // NOTE (LG): We're using a testing tool ClientProxy so that the miner has
    // its own client connection to network.
    // ClientProxy is an abstraction on top of Libra Client and other modules. (as with all testing tools) is unstable and in develoment.
    // TODO? Replace this implementation with LibraClient method,
    // instead of clientproxy which appears to be for testing.
    // There are API's for test servers, including faucet etc, which should not be there production.

    /// create the ClientProxy, with credentials, and point to network with a waypoint.
    let mut libra_client = ClientProxy::new_for_ol(
        /* url */ &node,
        /* mnemonic file */ &mnemonic_string,
        /* waypoint */ waypoint,
    )
    .map_err(|err| ErrorKind::Wallet.context(err))?;

    //TODO: ol-miner/submit_tx LibraWallet is not recovering all accounts.
    let sender_account = libra_client.accounts[0].address;

    libra_client
        .execute_send_proof(
            sender_account, // sender: &AccountData,
            challenge,      // challenge: Vec<u8>,
            difficulty,     // difficulty: u64,
            proof,          // proof: Vec<u8>
            true,
        )
        .map_err(|err| ErrorKind::Transaction.context(err))?;

    Ok(())
}
