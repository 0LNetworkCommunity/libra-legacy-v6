//# init --validators Alice
// Module to test bulk validator updates function in DiemSystem.move
// NOTE: enough balance for onboarding gas transfer.
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 3000000, 0, validator

// todo: fix this first: native_extract_address_from_challenge()
// https://github.com/OLSF/move-0L/blob/v6/language/move-stdlib/src/natives/ol_vdf.rs

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::VDF;
  use DiemFramework::TestFixtures;
  use DiemFramework::TowerState;
  use DiemFramework::DiemAccount;

  // Test Prefix: 1301

  fun main(_dr: signer, alice_sig: signer) {
    let challenge = TestFixtures::eve_0_easy_chal();
    let solution = TestFixtures::eve_0_easy_sol();
    // Parse key and check
    let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
    assert!(eve_addr == @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 401);
    
    let epochs_since_creation = 10;
    TowerState::test_helper_set_rate_limit(&alice_sig, epochs_since_creation);

    DiemAccount::create_validator_account_with_proof(
        &alice_sig,
        &challenge,
        &solution,
        TestFixtures::easy_difficulty(),
        TestFixtures::security(),
        b"leet",
        @0xfa72817f1b5aab94658238ddcdc08010,
        x"fa72817f1b5aab94658238ddcdc08010",
        x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010", // random consensus_pubkey: vector<u8>,
        b"192.168.0.1", // validator_network_addresses: vector<u8>,
        b"192.168.0.1", // fullnode_network_addresses: vector<u8>,
        x"1ee7", // human_name: vector<u8>,
    );
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::TowerState;
  use DiemFramework::TestFixtures;

  // SIMULATES A MINER ONBOARDING PROOF (proof_0.json)
  fun main(_: signer) { 
    let eve = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;
    let oper = @0xfa72817f1b5aab94658238ddcdc08010;

      let proof = TowerState::create_proof_blob(
        TestFixtures::eve_1_easy_chal(),
        TestFixtures::eve_1_easy_sol(),
        TestFixtures::easy_difficulty(), // difficulty
        TestFixtures::security(), // security
      );
      TowerState::test_helper_operator_submits(
        oper,
        eve,
        proof
      );

      // check for initialized TowerState
      let verified_tower_height_after = TowerState::test_helper_get_height(eve);

      assert!(verified_tower_height_after > 0, 10008001);
  }
}
// check: EXECUTED