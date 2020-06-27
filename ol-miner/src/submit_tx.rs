//! OlMiner submit_tx module
#![forbid(unsafe_code)]

pub mod submit_tx {
    use cli::client_proxy::ClientProxy;
    use libra_config::config::NodeConfig;

    // use crate::application::{MINER_MNEMONIC, DEFAULT_PORT};
    const DEFAULT_PORT: u64 = 2344; // TODO: this will likely deprecated in favor of urls and discovery.
    const MINER_MNEMONIC: &str = "./miner.mnemonic"; // TODO: change this
    const DEFAULT_NODE: &str = "src/config/test_data/single.node.config.toml";
    const ASSOCIATION_KEY_FILE: &str = "./mint.key"; // TODO: remove this


    pub fn submit_vdf_proof_tx_to_network(challenge: Vec<u8>, difficulty: u64, proof: Vec<u8>) {
        //! Functions for submitting proofs on chain


        let mut swarm_configs = NodeConfig::load(DEFAULT_NODE).expect("Unable to load config");

        // NOTE (LG): We're using a testing tool ClientProxy so that the miner has
        // its own client connection to network.
        // ClientProxy is an abstraction on top of Libra Client and other modules. (as with all testing tools) is unstable and in develoment.
        // TODO? Replace this implementation with LibraClient method,
        // instead of clientproxy which appears to be for testing.
        // There are API's for test servers, including faucet etc, which should not be there production.

        // create the ClientProxy, with credentials, and point to network with a waypoint.
        let mut libra_client = ClientProxy::new(
            /* url */ &format!("http://localhost:{}", DEFAULT_PORT),
            /* association account file */  ASSOCIATION_KEY_FILE, // TODO This is not needed for OL.
            /* sync_on_wallet_recovery */ false, // TODO (ZM): Should this be true?
            /* faucet server */ None,
            /* menmonic file */ Some(MINER_MNEMONIC.to_string()),
            /* waypoint */  // TODO: get from configs for tests something like: swarm_configs::BaseConfig.waypoint,
        );
        //
        // 2. Format Transaction
        // transaction data
        let sender;//: AccountData = ; // The miner's user's Address
        let sender_ref_id: usize = 0; // The user's index.???
        let sequence_number: u64 = 0; // should come from the network

        // self.accounts.get(sender_ref_id).unwrap();
        // let sequence_number = sender.sequence_number;

        libra_client.execute_send_proof(
            sender, // sender: &AccountData,
            sender_ref_id, // sender_ref_id: usize,
            sequence_number, // sequence_number: u64,
            challenge, // challenge: Vec<u8>,
            difficulty, // difficulty: u64,
            proof // proof: Vec<u8>
        )
    }
}
