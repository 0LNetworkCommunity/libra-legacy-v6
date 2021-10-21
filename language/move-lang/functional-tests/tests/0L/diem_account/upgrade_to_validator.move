//! account: bob, 10000000, 0, validator

//! new-transaction
//! sender: bob
script {
  use 0x1::DiemAccount;
  use 0x1::TestFixtures;
  use 0x1::GAS::GAS;

  fun main(sender: signer) {
    // Scenario: Bob, an existing user, is sending a transaction for Eve, 
    // with a challenge and proof not yet submitted to the chain.
    // This proof will create a new account, with the preimage data.
    let challenge = TestFixtures::eve_0_easy_chal();
    let solution = TestFixtures::eve_0_easy_sol();
    
    let eve_addr = DiemAccount::create_user_account_with_proof(
      &sender,
      &challenge,
      &solution,
      TestFixtures::easy_difficulty(), // difficulty
      TestFixtures::security(), // security
    );

    assert(DiemAccount::balance<GAS>(eve_addr) == 1000000, 735701);

    // is a slow wallet
    assert(!DiemAccount::is_slow(eve_addr), 735702);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
// use 0x1::VDF;
use 0x1::DiemAccount;
// use 0x1::TowerState;
use 0x1::TestFixtures;
// use 0x1::Vector;


// Test Prefix: 1301
fun main(sender: signer) {
  // Scenario: Bob, an existing validator, is sending a transaction for Eve, 
  // with a challenge and proof not yet submitted to the chain.
  let challenge = TestFixtures::eve_0_easy_chal();
  let solution = TestFixtures::eve_0_easy_sol();
  // // Parse key and check
  // let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
  // assert(eve_addr == @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 7357401001);
  
  // let epochs_since_creation = 10;
  // TowerState::test_helper_set_rate_limit(&sender, epochs_since_creation);

  DiemAccount::create_validator_account_with_proof(
      &sender,
      &challenge,
      &solution,
      TestFixtures::easy_difficulty(), // difficulty
      TestFixtures::security(), // security
      b"leet",
      @0xfa72817f1b5aab94658238ddcdc08010,
      x"fa72817f1b5aab94658238ddcdc08010",
      // random consensus_pubkey: vector<u8>,
      x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010", 
      b"192.168.0.1", // validator_network_addresses: vector<u8>,
      b"192.168.0.1", // fullnode_network_addresses: vector<u8>,
      x"1ee7", // human_name: vector<u8>,
  );

  // the prospective validator is in the current miner list.
  // assert(Vector::contains<address>(&TowerState::get_miner_list(), &eve_addr), 7357401002);
}
}
// check: EXECUTED



//! new-transaction
//! sender: diemroot
script {
use 0x1::EpochBoundary;
use 0x1::DiemAccount;
use 0x1::GAS::GAS;
use 0x1::ValidatorUniverse;
use 0x1::ValidatorConfig;

fun main(vm: signer) {
  let eve_addr = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;
  /// set the fullnode proof price to 0, to check if onboarding subsidy is given.
  // FullnodeSubsidy::test_set_fullnode_fixtures(&vm, 0, 0, 0, 0, 0);
  EpochBoundary::reconfigure(&vm, 10); 
    // need to remove testnet for this test, since testnet does not ratelimit 
    // account creation.
  let oper_eve = ValidatorConfig::get_operator(eve_addr);
  let bal = DiemAccount::balance<GAS>(oper_eve);
  // we expect 1 gas (1,000,000 microgas) from bob's transfer
  assert(bal == 1000000, 7357401003);

  // validator should have jailedbit
  assert(ValidatorUniverse::exists_jailedbit(eve_addr), 7357401004);
  // validator should be in universe if just joined.
  assert(ValidatorUniverse::is_in_universe(eve_addr), 7357401005);
  // should not be jailed
  assert(!ValidatorUniverse::is_jailed(eve_addr), 7357401006);
  // is a slow wallet
  assert(DiemAccount::is_slow(eve_addr), 7357401007);
}
}