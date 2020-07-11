// GOAL: To check that the preimage/challenge of a VDF proof contains a given address.
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

// Prepare the state for the next test.
// Bob Submits a CORRECT VDF Proof, and that updates the state.
//! account: alice, 10000000GAS
//! account: bob, 10000000GAS
//! new-transaction
//! sender: association
script {
use 0x0::Redeem;

fun main() {
  //NOTE: A valid ed25519 pubkey is 64 byte hex.
  //NOTE: A libra address is 32 byte hex.

  let challenge = x"232fb6ae7221c853232fb6ae7221c853232fb6ae7221c853232fb6ae7221c853";
  let new_account_address = 0x232fb6ae7221c853232fb6ae7221c853;
  // let auth_key_prefix = x"b7a3c12dc0c8c748ab07525b701122b88bd78f600c76342d27f25e5f92444cde";

  Redeem::first_challenge_includes_address(new_account_address, &challenge);
}
}
// check: EXECUTED
