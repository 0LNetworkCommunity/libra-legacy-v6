//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
use 0x0::VDF;
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;
use 0x0::MinerState;
use 0x0::NodeWeight;
use 0x0::TestFixtures;
use 0x0::ValidatorConfig;

// Test Prefix: 1301
fun main(_sender: &signer) {
  // Scenario: Bob, an existing validator, is sending a transaction for Eve, with a challenge and proof not yet submitted to the chain.
  let challenge = TestFixtures::eve_0_easy_chal();
  let solution = TestFixtures::eve_0_easy_sol();
  // Parse key and check
  let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
  Transaction::assert(eve_addr == 0x298cfd27ba6301c76ae5527fc64610b6, 401);
  LibraAccount::create_validator_account_with_vdf<GAS::T>(
    &challenge,
    &solution,
    x"deadbeef", // consensus_pubkey: vector<u8>,
    x"20d1ac", //validator_network_identity_pubkey: vector<u8>,
    b"192.168.0.1", //validator_network_address: vector<u8>,
    x"1ee7", //full_node_network_identity_pubkey: vector<u8>,
    b"192.168.0.1", //full_node_network_address: vector<u8>,
  );

  Transaction::assert(LibraAccount::is_certified<LibraAccount::ValidatorRole>(eve_addr), 7357130101011000);

  Transaction::assert(ValidatorConfig::is_valid(eve_addr), 7357130101021000);

  Transaction::assert(MinerState::test_helper_get_height(eve_addr) == 0, 7357130101031000);

  //Check the validator is in the validator universe.
  Transaction::assert(NodeWeight::proof_of_weight(eve_addr) == 0, 7357130101041000);

  // Check the account exists and the balance is 0
  Transaction::assert(LibraAccount::balance<GAS::T>(eve_addr) == 0, 7357130101051000);
}
}
// check: EXECUTED
