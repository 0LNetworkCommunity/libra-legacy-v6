// Test that validator accounts can be created from account addresses.

//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
use 0x0::Redeem;
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;
use 0x0::Debug;

fun main(sender: &signer) {
  let challenge = x"232fb6ae7221c853232fb6ae7221c853000000000000000000000000DEADBEEF";
  let new_account_address = 0xDEADBEEF;
  let auth_key_prefix = x"232fb6ae7221c853232fb6ae7221c853";

  Debug::print(&0x11e11000000003);
  Redeem::first_challenge_includes_address(new_account_address, challenge);
  Debug::print(&0x11e11000000004);
  // GOAL: it would be ideal that these accounts could be created by any Alice, for any Bob, i.e.
  // if it didn't need to be the association or system account.
  LibraAccount::create_validator_account_from_mining_0L<GAS::T>(sender, new_account_address, auth_key_prefix);

  // Check the account exists and the balance is 0
  Transaction::assert(LibraAccount::balance<GAS::T>(0xDEADBEEF) == 0, 0);

}
}
// check: EXECUTED
