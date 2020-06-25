//! OlMiner submit_tx module
#![forbid(unsafe_code)]

use cli;

pub mod submit_tx {
    pub fn create_account() {
        super::create_client_proxy()
    }
}

fn get_wallet() {
    let test = cli::client_proxy::ClientProxy::get_libra_wallet(Some("./client.mnemonic")).expect("nope");
}
fn create_client_proxy () {
    println!("hello" );
    // // TODO: This is copied from the Testsuite/client there may be a a different API.
    // // This is used for "smoke-tests" and we don't need faucet, wallet recovery or waypoint
    // // let s = "0xA550C1A8";
    // let libra_client = ClientProxy::new(
    //     // url: &str,
    //     // faucet_account_file: &str,
    //     // sync_on_wallet_recovery: bool,
    //     // faucet_server: Option<String>,
    //     // mnemonic_file: Option<String>,
    //     // waypoint: Waypoint,
    //
    //     &format!("http://localhost:{}", port),
    //     &self.faucet_key.1,
    //     false,
    //     /* faucet server */ None,
    //     Some(mnemonic_file_path),
    //     waypoint.unwrap_or_else(|| self.validator_swarm.config.waypoint),
    // );
}
// pub mod submit_tx {
//     //! Functions for submitting proofs on chain
//     // imports
//     use crate::application::SECURITY_PARAM;
//     use vdf::{VDFParams, WesolowskiVDFParams, VDF};
//     use cli::client_proxy::*;
//     // format transaction
//
//
//     // 1.Set Private Key file
//
//     let mnemonic_file_path = xyz
//
//     // 2. Format Transaction
//     // 3. Sign Transaction
//     // 4. Creat Client Proxy
//
//     pub fn create_client_proxy() {
//         // TODO: This is copied from the Testsuite/client there may be a a different API.
//         // This is used for "smoke-tests" and we don't need faucet, wallet recovery or waypoint
//         // let s = "0xA550C1A8";
//         let libra_client = ClientProxy::new(
//             // url: &str,
//             // faucet_account_file: &str,
//             // sync_on_wallet_recovery: bool,
//             // faucet_server: Option<String>,
//             // mnemonic_file: Option<String>,
//             // waypoint: Waypoint,
//
//             &format!("http://localhost:{}", port),
//             &self.faucet_key.1,
//             false,
//             /* faucet server */ None,
//             Some(mnemonic_file_path),
//             waypoint.unwrap_or_else(|| self.validator_swarm.config.waypoint),
//         );
//     }
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
// }
