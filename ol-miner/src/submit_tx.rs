//! OlMiner submit_tx module
#![forbid(unsafe_code)]

use cli::client_proxy::ClientProxy;
use libra_types::{
    waypoint::Waypoint,
    ledger_info::LedgerInfo,
    ledger_info::BlockInfo,
    on_chain_config::ValidatorSet
};

pub mod submit_tx {
    pub fn submit_vdf_proof_tx_to_network() {
        //! Functions for submitting proofs on chain

        // NOTE (LG): We're using a testing tool ClientProxy so that the miner has
        // its own client connection to network.
        // ClientProxy is an abstraction on top of Libra Client and other modules. (as with all testing tools) is unstable and in develoment.
        // TODO? Replace this implementation with LibraClient method,
        // instead of clientproxy which appears to be for testing.
        // There are API's for test servers, including faucet etc, which should not be there production.

        // 1.Set Private Key file

        MINER_MNEMONIC = "./miner.mnemonic";

        // 2. Format Transaction

        let port = 2344; // TODO: get port from /0_config/ files
        let sender;
        let sender_ref_id;
        let sequence_number;
        let challenge;
        let difficulty;
        let proof;

        // create the ClientProxy, with credentials, and point to network with a waypoint.
        let libra_client = ClientProxy::new(
            /* url */ &format!("http://localhost:{}", port),
            /* association keys for testing faucet */  &self.faucet_key.1, // TODO This is not needed for OL.
            /* sync_on_wallet_recovery */ false, // TODO (ZM): Should this be true?
            /* faucet server */ None,
            /* menmonic file */ Some(MINER_MNEMONIC),
            /* waypoint */ WaypointConfig::None, // TODO: Get from /0_Config/
        );

        libra_client.execute_send_proof(
            // sender: &AccountData,
            // sender_ref_id: usize,
            // sequence_number: u64,
            // challenge: Vec<u8>,
            // difficulty: u64,
            // proof: Vec<u8>
        )


    }
}
