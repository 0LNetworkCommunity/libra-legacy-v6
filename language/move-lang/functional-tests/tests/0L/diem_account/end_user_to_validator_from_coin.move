//! account: bob, 10000000, 0, validator


// Set up the test difficulty for dynamic vdf

//! new-transaction
//! sender: diemroot
script {
  use 0x1::TowerState;
  use 0x1::TestFixtures;
    fun main(vm: signer) {
      TowerState::test_set_vdf_difficulty(&vm, TestFixtures::easy_difficulty(), TestFixtures::security());
    }
}

// 1. create an end-user account for eve.

//! new-transaction
//! sender: bob
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;

  fun main(sender: signer) {
    // Eve's account info.

    let new_account: address = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;
    let new_account_authkey_prefix = x"2bffcbd0e9016013cb8ca78459f69d2b";
    let value = 1000000; // minimum is 1m microgas

    let eve_addr = DiemAccount::create_user_account_with_coin(
      &sender,
      new_account,
      new_account_authkey_prefix,
      value,
    );

    assert(DiemAccount::balance<GAS>(eve_addr) == 1000000, 735701);

    // is NOT a slow wallet
    assert(!DiemAccount::is_slow(eve_addr), 735702);
  }
}
// check: EXECUTED


// 2. Now that the account has been created, try to upgrade it to validator.

//! new-transaction
//! sender: bob
script {
use 0x1::DiemAccount;
use 0x1::TestFixtures;
use 0x1::ValidatorUniverse;


// Test Prefix: 1301
fun main(sender: signer) {
  // Scenario: Bob, an existing validator, is sending a transaction for Eve, 
  // with a challenge and proof not yet submitted to the chain.
  let challenge = TestFixtures::eve_0_easy_chal();
  let solution = TestFixtures::eve_0_easy_sol();

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
  assert(ValidatorUniverse::is_in_universe(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B), 735703);
}
}
// check: EXECUTED
