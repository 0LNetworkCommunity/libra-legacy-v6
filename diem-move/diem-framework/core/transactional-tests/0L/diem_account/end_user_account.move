//# init --parent-vasps Dave Bob
// Dave:     validators with 10M GAS
// Bob:  non-validators with  1M GAS

// todo: fix this first: native_extract_address_from_challenge()
// https://github.com/OLSF/move-0L/blob/v6/language/move-stdlib/src/natives/ol_vdf.rs

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::TestFixtures;
  use DiemFramework::GAS::GAS;

  fun main(_dr: signer, sender: signer) {
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

    assert!(DiemAccount::balance<GAS>(eve_addr) == 1000000, 735701);

    // is a slow wallet
    assert!(!DiemAccount::is_slow(eve_addr), 735702);
  }
}
// check: EXECUTED