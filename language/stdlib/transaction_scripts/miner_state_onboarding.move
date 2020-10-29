// Transaction script FOR ONBOARDING. Assumes tower-height 0, and that the challenge has a public key which will be turned into an auth_key and subsequently an address.
// The same algortihm for generating account addresses is available offline. This transaction confirms the address.
script {
use 0x1::LibraAccount;
use 0x1::GAS;
use 0x1::Transaction;
use 0x1::VDF;
use 0x1::ValidatorConfig;

fun main(
  challenge: vector<u8>,
  solution: vector<u8>,
  consensus_pubkey: vector<u8>,
  validator_network_identity_pubkey: vector<u8>,
  validator_network_address: vector<u8>,
  full_node_network_identity_pubkey: vector<u8>,
  full_node_network_address: vector<u8>,
  // expected_address: address // UX: seems redundant but it's for the user to doubly check they know the address.
) {
    // Parse key and check
    let (parsed_address, _auth_key_prefix) = VDF::extract_address_from_challenge(&challenge);

    // Sanity check the user knows the address that will be used.
    // Transaction::assert(expected_address == parsed_address, 01);

    LibraAccount::create_validator_account_with_vdf<GAS::T>(
      &challenge,
      &solution,
      consensus_pubkey,
      validator_network_identity_pubkey,
      validator_network_address,
      full_node_network_identity_pubkey,
      full_node_network_address,
    );

    // Check the account has the Validator role
    Transaction::assert(LibraAccount::is_certified<LibraAccount::ValidatorRole>(parsed_address), 02);

    Transaction::assert(ValidatorConfig::is_valid(parsed_address), 03);


    // Check the account exists and the balance is 0
    Transaction::assert(LibraAccount::balance<GAS::T>(parsed_address) == 0, 04);

}
}
