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
    pub fn create_account() {
        //     //! Functions for submitting proofs on chain

        //     // 1.Set Private Key file
        //
        //     let mnemonic_file_path = xyz
        //
        //     // 2. Format Transaction
        //     // 3. Sign Transaction
        //     // 4. Create Client Proxy
                super::create_client_proxy()
        //
        //     // 5. Execute submission with ClientProxy
        //     fn execute(
        //         client: ClientProxy,
        //         sender: &AccountData,
        //         sender_ref_id: usize,
        //         sequence_number: u64,
        //         challenge: Vec<u8>,
        //         difficulty: u64,
        //         proof: Vec<u8> ) {
        //     //submit transaction
        //     match client.execute_send_proof(
        //         sender,
        //         sender_ref_id,
        //         sequence_number,
        //         challenge,
        //         difficulty,
        //         proof) {
        //             Ok( _) => println!("succeed." ),
        //             Err(e) => report_error("Failed to send proof", e),
        //         }
        //     }
        //
        //     // check tranaction submitted


    }
}

fn get_wallet() {

}
fn create_client_proxy () {
    // // TODO: This is copied from the Testsuite/client there may be a a different API.

    // let test = ClientProxy::get_libra_wallet(Some("./client.mnemonic".to_string())).expect("nope");
    let port = 2344; // TODO: get port from /0_config/ files
    // TODO: Replace this with LibraClient method, instead of clientproxy which appears to be for testing.
    //let waypoint = Waypoint::new_epoch_boundary(&li).unwrap();
    let waypoint =
        Waypoint::new_epoch_boundary(&LedgerInfo::mock_genesis(Some(ValidatorSet::empty())))
            .unwrap();

    let libra_client = ClientProxy::new(
        /* url */ &format!("http://localhost:{}", port),
        /* faucet/admin keys */  &self.faucet_key.1,
        /* sync_on_wallet_recovery */ false,
        /* faucet server */ None,
        /* menmonic file */ Some("./client.mnemonic".to_string()),
        /* waypoint */ WaypointConfig::None, // TODO: Get from /0_Config/
    );
}

// fn test_waypoint() -> Waypoint {
//     let li = LedgerInfo::new(
//         BlockInfo::new(
//             1,
//             10,
//             HashValue::random(),
//             HashValue::random(),
//             123,
//             1000,
//             Some(EpochState::empty()),
//         ),
//         HashValue::zero(),
//     );
//     Waypoint::new_epoch_boundary(&li).unwrap();
// }
// pub mod submit_tx {

// }
