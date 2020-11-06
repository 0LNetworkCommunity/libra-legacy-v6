// Transaction script FOR ONBOARDING. Assumes tower-height 0, and that the challenge has a public key which will be turned into an auth_key and subsequently an address.
// The same algortihm for generating account addresses is available offline. This transaction confirms the address.
script {
use 0x1::LibraAccount;
use 0x1::GAS::GAS;
// use 0x1::Transaction;
// use 0x1::VDF;
use 0x1::ValidatorConfig;

fun minerstate_onboarding(
  challenge: vector<u8>,
  solution: vector<u8>,
  consensus_pubkey: vector<u8>,
  validator_network_address: vector<u8>,
  full_node_network_address: vector<u8>,
  human_name: vector<u8>,
) {

    let new_account_address = LibraAccount::create_validator_account_with_proof(
      &challenge,
      &solution,
      consensus_pubkey,
      validator_network_address,
      full_node_network_address,
      human_name
    );
  //   LibraAccount::create_validator_account_with_proof(
  //   &challenge,
  //   &solution,
  //   x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010", // consensus_pubkey: vector<u8>,
  //   b"192.168.0.1", // validator_network_addresses: vector<u8>,
  //   b"192.168.0.1", // fullnode_network_addresses: vector<u8>,
  //   x"1ee7", // human_name: vector<u8>,
  // );

    // Check the account has the Validator role
    assert(ValidatorConfig::is_valid(new_account_address), 03);

    // Check the account exists and the balance is 0
    assert(LibraAccount::balance<GAS>(new_account_address) == 0, 04);

}
}
