//# init --parent-vasps Dave Bob
// Dave:     validators with 10M GAS
// Bob:  non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::TestFixtures;
  use DiemFramework::GAS::GAS;

  fun main(dr: signer, sender: signer) {

    // Make Bob's balance more than 1M
    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Dave,
      @Bob,
      100,
      x"",
      x"",
      &dr
    );

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