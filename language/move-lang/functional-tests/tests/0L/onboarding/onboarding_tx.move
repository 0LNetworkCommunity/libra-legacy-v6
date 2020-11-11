//! account: dummy-prevents-genesis-reload, 100000, 0, validator

//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
use 0x1::VDF;
use 0x1::LibraAccount;
use 0x1::GAS::GAS;
use 0x1::MinerState;
use 0x1::NodeWeight;
use 0x1::TestFixtures;
use 0x1::ValidatorConfig;
use 0x1::Roles;

// Test Prefix: 1301
fun main(_sender: &signer) {
  // Scenario: Bob, an existing validator, is sending a transaction for Eve, with a challenge and proof not yet submitted to the chain.
  let challenge = TestFixtures::eve_0_easy_chal();
  let solution = TestFixtures::eve_0_easy_sol();
  // Parse key and check
  let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
  assert(eve_addr == 0x22172b8d4d5ccc8c13bca0981ef986ef, 401);
 
  LibraAccount::create_validator_account_with_proof(
      &challenge,
      &solution,
      x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010", // consensus_pubkey: vector<u8>,
      b"192.168.0.1", // validator_network_addresses: vector<u8>,
      b"192.168.0.1", // fullnode_network_addresses: vector<u8>,
      x"1ee7", // human_name: vector<u8>,
  );

  assert(Roles::assert_validator_addr(eve_addr), 7357130101011000);
  assert(ValidatorConfig::is_valid(eve_addr), 7357130101021000);

  assert(MinerState::test_helper_get_height(eve_addr) == 0, 7357130101031000);

  //Check the validator is in the validator universe.
  assert(NodeWeight::proof_of_weight(eve_addr) == 0, 7357130101041000);

  // Check the account exists and the balance is 0
  assert(LibraAccount::balance<GAS>(eve_addr) == 0, 7357130101051000);
}
}
// check: EXECUTED