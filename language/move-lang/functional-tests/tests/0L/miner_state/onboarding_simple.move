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

    fun main(_account: &signer) {
    let challenge = TestFixtures::alice_1_easy_chal();
    let solution = TestFixtures::alice_1_easy_sol();
    let (parsed_address, _auth_key_prefix) = VDF::extract_address_from_challenge(&challenge);


    LibraAccount::create_validator_account_with_vdf<GAS::T>(
      &challenge,
      &solution,
    );

    // Check the account has the Validator role
    assert(LibraAccount::is_certified<LibraAccount::ValidatorRole>(parsed_address), 02);

    assert(ValidatorConfig::is_valid(parsed_address), 03);


    // Check the account exists and the balance is 0
    assert(LibraAccount::balance<GAS::T>(parsed_address) == 0, 03);
    }
}
//check: EXECUTED