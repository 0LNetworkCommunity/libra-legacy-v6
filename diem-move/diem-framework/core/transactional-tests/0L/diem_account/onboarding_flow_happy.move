//# init --validators Bob

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::VDF;
  use DiemFramework::DiemAccount;
  use DiemFramework::TowerState;
  use DiemFramework::TestFixtures;
  use Std::Vector;

  // Test Prefix: 1301
  fun main(_dr: signer, sender: signer) {
    // Scenario: Bob, an existing validator, is sending a transaction for Eve, 
    // with a challenge and proof not yet submitted to the chain.
    let challenge = TestFixtures::eve_0_easy_chal();
    let solution = TestFixtures::eve_0_easy_sol();
    // Parse key and check
    let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
    assert!(eve_addr == @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 7357401001);
    
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
    assert!(Vector::contains<address>(&TowerState::get_miner_list(), &eve_addr), 7357401002);
  }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::EpochBoundary;
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::ValidatorUniverse;

  fun main(vm: signer, _: signer) {
    let eve_addr = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;

    let bal = DiemAccount::balance<GAS>(eve_addr);
    // we expect 1 gas (1,000,000 microgas) from bob's transfer
    assert!(bal == 1000000, 7357401003);
    
    // set the fullnode proof price to 0, to check if onboarding subsidy is given.
    EpochBoundary::reconfigure(&vm, 10); 
      // need to remove testnet for this test, since testnet does not ratelimit 
      // account creation.
    
    let bal = DiemAccount::balance<GAS>(eve_addr);
    // After the epoch turned over Eve paid the epoch Burn of 1 coin.
    assert!(bal == 0, 7357401004);

    // validator should have jailedbit
    assert!(ValidatorUniverse::exists_jailedbit(eve_addr), 7357401005);
    // validator should be in universe if just joined.
    assert!(ValidatorUniverse::is_in_universe(eve_addr), 7357401006);
    // should not be jailed
    assert!(!ValidatorUniverse::is_jailed(eve_addr), 7357401007);
  }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::TowerState;

  fun main(vm: signer, _: signer) {
    let eve_addr = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;
    // mock mining above threshold.
    TowerState::test_helper_mock_mining_vm(&vm, eve_addr, 100);
  }
}

// Validator is done sycning the node, and sends join transaction.

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::TowerState;
  use DiemFramework::DiemAccount;
  use DiemFramework::ValidatorUniverse;

  fun main(vm: signer, _: signer) {
    // simulate join validator set transaction
    let eve_addr = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;
    // let addr = Signer::address_of(validator);
    // if is above threshold continue, or raise error.
    let new_signer = DiemAccount::test_helper_create_signer(&vm, eve_addr);
    assert!(TowerState::node_above_thresh(eve_addr), 7357401007);
    // if is not in universe, add back
    if (!ValidatorUniverse::is_in_universe(eve_addr)) {
        ValidatorUniverse::add_self(&new_signer);
    };
    // if is jailed, try to unjail
    if (ValidatorUniverse::is_jailed(eve_addr)) {
        ValidatorUniverse::unjail_self(&new_signer);
    };
  }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::ValidatorUniverse;

  fun main() {
    let eve_addr = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;
    // set the fullnode proof price to 0, to check if onboarding subsidy is given.
    // mock mining above threshold.
    assert!(ValidatorUniverse::exists_jailedbit(eve_addr), 7357401008);
    assert!(ValidatorUniverse::is_in_universe(eve_addr), 7357401009);
    assert!(!ValidatorUniverse::is_jailed(eve_addr), 7357401010);
  }
}