//! account: alice, 100000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator

// Tests the prologue reconfigures based on wall clock

//! block-prologue
//! proposer: alice
//! block-time: 1
//! round: 1


//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    use 0x1::Debug::print;

    fun main(_sender: signer) {
        let a = TowerState::toy_rng(1, 1);
        // check the state started with the testnet defaults
        assert(a==116, 735701);
        // modulo 5 is 1, so it should have same answer
        let a = TowerState::toy_rng(5, 1);
        assert(a==116, 735702);

        // get the 0th miner's last proof hash
        let a = TowerState::toy_rng(0, 1);
        print(&a);
    }
}


//! new-transaction
//! sender: alice
script {
use 0x1::VDF;
use 0x1::DiemAccount;
use 0x1::TowerState;
use 0x1::TestFixtures;
use 0x1::Vector;


// Test Prefix: 1301
fun main(sender: signer) {
  // Scenario: Bob, an existing validator, is sending a transaction for Eve, 
  // with a challenge and proof not yet submitted to the chain.
  let challenge = TestFixtures::eve_0_easy_chal();
  let solution = TestFixtures::eve_0_easy_sol();
  // // Parse key and check
  let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
  assert(eve_addr == @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 7357401001);
  
  let epochs_since_creation = 10;
  TowerState::test_helper_set_rate_limit(&sender, epochs_since_creation);

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
  assert(Vector::contains<address>(&TowerState::get_miner_list(), &eve_addr), 7357401002);
}
}
// check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;

    fun main(_sender: signer) {
        // get the 5th miner's last proof hash
        let a = TowerState::toy_rng(4, 1);
        assert(a==160, 735703);

        // get the 5th miner's last proof hash, and then iterate a second time
        let a = TowerState::toy_rng(4, 2);
        assert(a==116, 735703);
    }
}
