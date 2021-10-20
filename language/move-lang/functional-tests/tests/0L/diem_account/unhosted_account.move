//! account: bob, 10000000, 0

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