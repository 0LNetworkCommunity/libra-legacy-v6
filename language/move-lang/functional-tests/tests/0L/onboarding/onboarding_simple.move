// Module to test bulk validator updates function in LibraSystem.move
//! account: alice, 1000000, 0, validator

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction::assert;
    use 0x0::LibraAccount;
    use 0x0::GAS;
    use 0x0::TestFixtures;
    use 0x0::VDF;
    use 0x0::ValidatorConfig;

    fun main(_sender: &signer) {
    let challenge = TestFixtures::alice_1_easy_chal();
    let solution = TestFixtures::alice_1_easy_sol();
    let (parsed_address, _auth_key_prefix) = VDF::extract_address_from_challenge(&challenge);


    LibraAccount::create_validator_account_with_vdf<GAS::T>(
      &challenge,
      &solution,
      x"deadbeef", // consensus_pubkey: vector<u8>,
      x"20d1ac", //validator_network_identity_pubkey: vector<u8>,
      b"192.168.0.1", //validator_network_address: vector<u8>,
      x"1ee7", //full_node_network_identity_pubkey: vector<u8>,
      b"192.168.0.1", //full_node_network_address: vector<u8>,
    );

    // ValidatorConfig::set_init_config(
    //   sender,
    //   parsed_address,
    //   x"", // consensus_pubkey: vector<u8>,
    //   x"", //validator_network_identity_pubkey: vector<u8>,
    //   x"", //validator_network_address: vector<u8>,
    //   x"", //full_node_network_identity_pubkey: vector<u8>,
    //   x"", //full_node_network_address: vector<u8>,
    // );


    // Check the account has the Validator role
    assert(LibraAccount::is_certified<LibraAccount::ValidatorRole>(parsed_address), 7357130101011000);

    assert(ValidatorConfig::is_valid(parsed_address), 7357130101021000);


    // Check the account exists and the balance is 0
    assert(LibraAccount::balance<GAS::T>(parsed_address) == 0, 7357130101031000);
    }
}
//check: EXECUTED