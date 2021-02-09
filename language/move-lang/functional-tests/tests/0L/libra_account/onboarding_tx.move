//! account: bob, 100000, 0, validator

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
use 0x1::Signer;
use 0x1::Debug::print;
// Test Prefix: 1301
fun main(sender: &signer) {
  // // Scenario: Bob, an existing validator, is sending a transaction for Eve, with a challenge and proof not yet submitted to the chain.
  let challenge = TestFixtures::eve_0_easy_chal();
  let solution = TestFixtures::eve_0_easy_sol();
  // // Parse key and check
  let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
  assert(eve_addr == 0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 401);
  
  let sender_addr = Signer::address_of(sender);
  let epochs_since_creation = 10;
  MinerState::test_helper_set_rate_limit(sender_addr, epochs_since_creation);

  LibraAccount::create_validator_account_with_proof(
      sender,
      &challenge,
      &solution,
      b"leet",
      0xfa72817f1b5aab94658238ddcdc08010,
      x"fa72817f1b5aab94658238ddcdc08010",
      x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010", // random consensus_pubkey: vector<u8>,
      b"192.168.0.1", // validator_network_addresses: vector<u8>,
      b"192.168.0.1", // fullnode_network_addresses: vector<u8>,
      x"1ee7", // human_name: vector<u8>,
  );

  assert(Roles::assert_validator_addr(eve_addr), 7357130101011000);
  assert(Roles::assert_validator_operator_addr(0xfa72817f1b5aab94658238ddcdc08010), 7357130101021000);

  assert(ValidatorConfig::is_valid(eve_addr), 7357130101031000);
  assert(ValidatorConfig::get_operator(eve_addr) == 0xfa72817f1b5aab94658238ddcdc08010, 7357130101041000);
  
  let config = ValidatorConfig::get_config(eve_addr);
  let consensus_pubkey = ValidatorConfig::get_consensus_pubkey(&config);
  assert(consensus_pubkey == &x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010", 7357130101051000);

  assert(MinerState::test_helper_get_height(eve_addr) == 0, 7357130101061000);

  //Check the validator is in the validator universe.
  assert(NodeWeight::proof_of_weight(eve_addr) == 0, 7357130101071000);

  // Check the account exists and the balance is 0
  // TODO: Needs some balance
  print(&LibraAccount::balance<GAS>(eve_addr));
  assert(LibraAccount::balance<GAS>(eve_addr) == 0, 7357130101081000);

  // Is rate-limited
  assert(MinerState::rate_limit_create_acc(sender_addr) == false, 7357130101091000);
}
}
// check: EXECUTED
