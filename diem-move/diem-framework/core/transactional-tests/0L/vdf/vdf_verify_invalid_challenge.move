// NOTE: TEST SETUP: If you add a "validator", functional tests will add 
// only that validator to genesis.
// By default 0L tests load 3 random validators on genesis. This is slow. 
// So adding a dummy validator will only run the initialize_miners once 
// instead of three times, and speeds up testing.

//! new-transaction
script{
  use DiemFramework::VDF;
  use DiemFramework::TestFixtures;
  fun main() {
    // This checks that the VDF verifier catches an invalide "challenge" 
    // parameter, and fails gracefully with error.

    // incorrect challenge.
    let wrong_challenge = b"aa";
    // Generate solutions with:
    // cd ./verfiable_delay/vdf-cli && cargo run --release -- -l=512 aa 100 -tpietrzak
    // NOTE: the -l=512 is important because this is the security paramater of 0L miner.
    let proof = TestFixtures::alice_0_easy_sol();

    let res = VDF::verify(
      &wrong_challenge,
      &proof,
      &TestFixtures::easy_difficulty(), // difficulty
      &TestFixtures::security(), // security
    );

    assert!( res == false, 1);
  }
}