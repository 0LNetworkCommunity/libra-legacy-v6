// Test that validator accounts can be created from account addresses.

// Prepare the state for the next test.
// Bob Submits a CORRECT VDF Proof, and that updates the state.
//! account: alice, 10000000GAS
//! account: bob, 10000000GAS
//! new-transaction
//! sender: association
script {
// use 0x0::Redeem;
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;

fun main(sender: &signer) {
  let _challenge = x"232fb6ae7221c853232fb6ae7221c8538765432123";
  let new_account_address = 0xDEADBEEF;
  let auth_key_prefix = x"232fb6ae7221c853232fb6ae7221c853";

  // Redeem::first_challenge_matches_address(add, challenge);
  // GOAL: it would be ideal that these accounts could be created by any Alice, for any Bob, i.e.
  // if it didn't need to be the association or system account.
  LibraAccount::create_validator_account<GAS::T>(sender, new_account_address, auth_key_prefix);

  // Check the account exists and the balance is 0
  Transaction::assert(LibraAccount::balance<GAS::T>(0xDEADBEEF) == 0, 0);

}
}
// check: EXECUTED
