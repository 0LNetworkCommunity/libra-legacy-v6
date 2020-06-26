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
        //     //! Functions for submitting proofs on chain

        //     // 1.Set Private Key file
        //
        MINER_MNEMONIC = "./miner.mnemonic";
        //
        //     // 2. Format Transaction
        //     // 3. Sign Transaction
        //     // 4. Create Client Proxy
        // // TODO: This is copied from the Testsuite/client there may be a a different API.

        let port = 2344; // TODO: get port from /0_config/ files
        let sender;
        let sender_ref_id;
        let sequence_number;
        let challenge;
        let difficulty;
        let proof;

        // TODO: Replace this with LibraClient method, instead of clientproxy which appears to be for testing.

        let libra_client = ClientProxy::new(
            /* url */ &format!("http://localhost:{}", port),
            /* faucet/admin keys */  &self.faucet_key.1,
            /* sync_on_wallet_recovery */ false,
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
