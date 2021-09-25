//! account: bob, 10000000, 0, validator

//! new-transaction
//! sender: bob
script {
  use 0x1::DiemAccount;
  use 0x1::TestFixtures;
  use 0x1::GAS::GAS;

  fun main(_sender: signer) {
    // Scenario: Bob, an existing user, is sending a transaction for Eve, 
    // with a challenge and proof not yet submitted to the chain.
    // This proof will create a new account, with the preimage data.
    let challenge = TestFixtures::eve_0_easy_chal();
    let solution = TestFixtures::eve_0_easy_sol();
    
    let eve_addr = DiemAccount::create_user_account_with_proof(
      &challenge,
      &solution,
    );

    assert(DiemAccount::balance<GAS>(eve_addr) == 0, 735701);

    // is a slow wallet
    assert(DiemAccount::is_slow(eve_addr), 735702);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
// use 0x1::VDF;
use 0x1::DiemAccount;
// use 0x1::MinerState;
use 0x1::TestFixtures;
// use 0x1::Signer;
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
  
  // let sender_addr = Signer::address_of(&sender);
  // let epochs_since_creation = 10;
  // MinerState::test_helper_set_rate_limit(sender_addr, epochs_since_creation);

  DiemAccount::create_validator_account_with_proof(
      &sender,
      &challenge,
      &solution,
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
  // assert(Vector::contains<address>(&MinerState::get_miner_list(), &eve_addr), 7357401002);
}
}
// check: EXECUTED