//! account: bob, 100000, 0

//! new-transaction
//! sender: bob
script {
use 0x1::VDF;
use 0x1::LibraAccount;
use 0x1::TestFixtures;
use 0x1::GAS::GAS;

fun main(_sender: &signer) {
  // Scenario: Bob, an existing user, is sending a transaction for Eve, with a challenge and proof not yet submitted to the chain.
  // This proof will create a new account, with the preimage data.
  let challenge = TestFixtures::eve_0_easy_chal();
  let solution = TestFixtures::eve_0_easy_sol();
  // // Parse key and check
  let (eve_addr, auth_key_prefix) = VDF::extract_address_from_challenge(&challenge);

  LibraAccount::create_user_account_with_proof(
    &challenge,
    &solution,
    eve_addr,
    auth_key_prefix,
  );

  assert(LibraAccount::balance<GAS>(eve_addr) == 0, 7357130101081000);
}
}
// check: EXECUTED
