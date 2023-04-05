//# init --validators Alice

// We are testing one validator creating another validator account

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::TestFixtures;
  use Std::Signer;
  use DiemFramework::VDF;
  use DiemFramework::ValidatorConfig;
  use DiemFramework::Roles;
  use DiemFramework::TowerState;
  use DiemFramework::Testnet;
  // use DiemFramework::Debug::print;

  fun main(dr: signer, sender: signer) {
    let sender_addr = Signer::address_of(&sender);
    assert!(TowerState::can_create_val_account(sender_addr) == true, 7357001);
    

    let challenge = TestFixtures::eve_0_easy_chal();
    let solution = TestFixtures::eve_0_easy_sol();
    let (parsed_address, _auth_key_prefix) = VDF::extract_address_from_challenge(&challenge);

    let epochs_since_creation = 6;
    TowerState::test_helper_set_rate_limit(&sender, epochs_since_creation);

    DiemAccount::create_validator_account_with_proof(
        &sender,
        &challenge,
        &solution,
        TestFixtures::easy_difficulty(), // difficulty
        TestFixtures::security(), // security
        b"leet",
        @0xfa72817f1b5aab94658238ddcdc08010,
        x"fa72817f1b5aab94658238ddcdc08010",
        x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010", // random consensus_pubkey: vector<u8>,
        b"192.168.0.1", // validator_network_addresses: vector<u8>,
        b"192.168.0.1", // fullnode_network_addresses: vector<u8>,
        x"1ee7", // human_name: vector<u8>,
    );

    // Check the account has the Validator role
    assert!(Roles::assert_validator_addr(parsed_address), 7357002);
    assert!(ValidatorConfig::is_valid(parsed_address), 7357003);

    // Check that the Onboarder Alice, was able to deposit funds to the net validator account
    // print(&DiemAccount::balance<GAS>(parsed_address));
    assert!(DiemAccount::balance<GAS>(parsed_address) == 1000000, 7357004);

    Testnet::remove_testnet(&dr); // testnet would make this always true
    assert!(TowerState::can_create_val_account(sender_addr) == false, 7357005);
  }
}