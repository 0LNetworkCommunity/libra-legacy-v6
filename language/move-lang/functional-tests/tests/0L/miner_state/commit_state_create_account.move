// Test that validator accounts can be created from account addresses.
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
use 0x1::VDF;
use 0x1::LibraAccount;
use 0x1::GAS::GAS;

fun main(sender: &signer) {
  let challenge = x"232fb6ae7221c853232fb6ae7221c853000000000000000000000000DEADBEEF";
  // Parse key and check
  let (parsed_address, auth_key) = VDF::extract_address_from_challenge(&challenge);
  // GOAL: it would be ideal that these accounts could be created by any Alice, for any Bob, i.e.
  // if it didn't need to be the association or system account.
  //  ^ I think this is working with `create_validator_account_from_mining_0L`
  LibraAccount::create_validator_account_from_mining_0L<GAS>(sender, parsed_address, auth_key, b"owner_name");
  // Check the account exists and the balance is 0
  assert(LibraAccount::balance<GAS>(parsed_address) == 0, 0);

}
}
// check: EXECUTED
