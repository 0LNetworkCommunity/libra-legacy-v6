//! OlMiner submit_tx module
#![forbid(unsafe_code)]

use cli::client_proxy::ClientProxy;
use libra_types::{
    waypoint::Waypoint,
    ledger_info::LedgerInfo,
    ledger_info::BlockInfo,
    on_chain_config::ValidatorSet
};

use crate::application::{MINER_MNEMONIC, SWARM_DEV_PORT};


pub mod submit_tx {
    pub fn submit_vdf_proof_tx_to_network(challenge: Vec<u8>, difficulty: u64, proof: Vec<u8>) {
        //! Functions for submitting proofs on chain

        // NOTE (LG): We're using a testing tool ClientProxy so that the miner has
        // its own client connection to network.
        // ClientProxy is an abstraction on top of Libra Client and other modules. (as with all testing tools) is unstable and in develoment.
        // TODO? Replace this implementation with LibraClient method,
        // instead of clientproxy which appears to be for testing.
        // There are API's for test servers, including faucet etc, which should not be there production.

        // create the ClientProxy, with credentials, and point to network with a waypoint.
        let libra_client = clientproxy::ClientProxy::new(
            /* url */ &format!("http://localhost:{}", SWARM_DEV_PORT),
            /* association keys for testing faucet */  &self.faucet_key.1, // TODO This is not needed for OL.
            /* sync_on_wallet_recovery */ false, // TODO (ZM): Should this be true?
            /* faucet server */ None,
            /* menmonic file */ Some(MINER_MNEMONIC),
            /* waypoint */ WaypointConfig::None, // TODO: Get from /0_Config/
        );

        // 2. Format Transaction
        // transaction data
        let sender;//: AccountData = ; // The miner's user's Address
        let sender_ref_id: usize = 0; // The user's index.???
        let sequence_number: u64 = 0; // should come from the network

        self.accounts.get(sender_ref_id).unwrap();
        let sequence_number = sender.sequence_number;

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
