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
    pub fn submit_vdf_proof_tx_to_network(
        challenge: Vec<u8>,// challenge;
        difficulty: u64,// difficulty;
        proof: Vec<u8>// proof;
    ) {
        //! Functions for submitting proofs on chain

        // NOTE (LG): So that the miner has its own client connection to network, well use
        // a testing tool ClientProxy. ClientProxy is an abstraction on top of Libra Client and other modules.
        // As with all testing tools it is unstable and in develoment.
        // TODO? Once POC is achieved, we should replace this implementation with LibraClient method directly,
        // instead of clientproxy which appears to be for testing.
        // There are API's for test servers, including faucet etc, which should not be there production.

        // 1.Set Private Key file

        const MINER_MNEMONIC: str = "./miner.mnemonic";


        // create the ClientProxy, with credentials, and point to network with a waypoint.
        let libra_client = ClientProxy::new(
            /* url */ &format!("http://localhost:{}", port),
            /* association keys for testing faucet */  &self.faucet_key.1, // TODO This is not needed for OL.
            /* sync_on_wallet_recovery */ false, // TODO (ZM): Should this be true?
            /* faucet server */ None,
            /* menmonic file */ Some(MINER_MNEMONIC),
            /* waypoint */ WaypointConfig::None, // TODO: Get from /0_Config/
        );


        // 2. Format Transaction
        // transaction data
        let port = 2344; // TODO: get port from /0_config/ files
        let sender;//: AccountData = ; // The miner's user's Address
        let sender_ref_id: usize = 0; // The user's index.???
        let sequence_number: u64 = 0; // should come from the network

        self.accounts.get(sender_ref_id).unwrap();
        let sequence_number = sender.sequence_number;

        libra_client.execute_send_proof(
            // sender: &AccountData,
            sender_ref_id = self.get_account_ref_id(sender), // sender_ref_id: usize,
            sequence_number, // sequence_number: u64,
            challenge, // challenge: Vec<u8>,
            difficulty, // difficulty: u64,
            proof// proof: Vec<u8>
        )


    }
}
