//! account: alice, 4000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator

//! new-transaction
//! sender: alice
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::ValidatorConfig;
  use DiemFramework::TestFixtures;
  use DiemFramework::VDF;
  use DiemFramework::TowerState;

  fun main(sender: signer) {
    // Scenario: Alice, an existing validator, is sending a transaction for Eve, 
    // with a challenge and proof from eve's block_0
    let challenge = TestFixtures::eve_0_easy_chal();
    let solution = TestFixtures::eve_0_easy_sol();
    // // Parse key and check
    let (eve_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
    assert!(eve_addr == @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 401);

    let epochs_since_creation = 10;
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
        // random consensus_pubkey: vector<u8>,
        x"8108aedfacf5cf1d73c67b6936397ba5fa72817f1b5aab94658238ddcdc08010",
        b"192.168.0.1", // validator_network_addresses: vector<u8>,
        b"192.168.0.1", // fullnode_network_addresses: vector<u8>,
        x"1ee7", // human_name: vector<u8>,
    );
    assert!(ValidatorConfig::is_valid(eve_addr), 7357130101031000);

  }
}
//check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use DiemFramework::AutoPay;
    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
    }
}

//! new-transaction
//! sender: bob
script {
    use DiemFramework::AutoPay;
    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
    }
}

//! new-transaction
//! sender: carol
script {
    use DiemFramework::AutoPay;
    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
    }
}

//! new-transaction
//! sender: dave
script {
    use DiemFramework::AutoPay;
    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
    }
}


//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::EpochBoundary;
    use Std::Vector;
    use DiemFramework::TowerState;
    use DiemFramework::Stats;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main(vm: signer) {
        let vm = &vm;
        // Tests on initial size of validators
        assert!(DiemSystem::validator_set_size() == 4, 7357000180101);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357000180102);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357000180103);
        assert!(
            DiemSystem::is_validator(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B) == false, 
            7357000180104
        );
        assert!(TowerState::is_init(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B), 7357000180105);

        TowerState::test_helper_mock_mining_vm(vm, @Alice, 20);
        TowerState::test_helper_mock_mining_vm(vm, @Bob, 20);
        TowerState::test_helper_mock_mining_vm(vm, @Carol, 20);
        TowerState::test_helper_mock_mining_vm(vm, @Dave, 20);

        // Transfer coins to operators
        let oper_alice = ValidatorConfig::get_operator(@Alice);
        let oper_bob = ValidatorConfig::get_operator(@Bob);
        let oper_carol = ValidatorConfig::get_operator(@Carol);
        let oper_dave = ValidatorConfig::get_operator(@Dave);
        DiemAccount::vm_make_payment_no_limit<GAS>( @Alice, oper_alice, 60009, x"", x"", vm);  
        DiemAccount::vm_make_payment_no_limit<GAS>( @Bob, oper_bob, 60009, x"", x"", vm);  
        DiemAccount::vm_make_payment_no_limit<GAS>( @Carol, oper_carol, 60009, x"", x"", vm);  
        DiemAccount::vm_make_payment_no_limit<GAS>( @Dave, oper_dave, 60009, x"", x"", vm);

        // Mock everyone being a CASE 1
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };

        EpochBoundary::reconfigure(vm, 15); // reconfigure at height 15
        assert!(DiemSystem::validator_set_size() == 4, 7357000180106);
    }
}
// check: EXECUTED

// Epoch 2 began
// The new node is in validatorUniverse but not in validator set

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;
    fun main(vm: signer) {
        // Tests on initial size of validators
        // New validator is not in this set.
        assert!(DiemSystem::validator_set_size() == 4, 7357000180101);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357000180102);
        assert!(!DiemSystem::is_validator(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B), 7357000180103);
        let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(&vm));
        // Is in validator universe
        assert!(len == 5, 7357000180104);
      }
}
// check: EXECUTED

// The new node starts mining and submiting proofs in the epoch 2
//
//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::EpochBoundary;
    use Std::Vector;
    use DiemFramework::TowerState;
    use DiemFramework::Stats;
    use DiemFramework::ValidatorUniverse;
    use DiemFramework::AutoPay;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;    

    fun main(vm: signer) {
        let vm = &vm;
        // Tests on initial size of validators
        assert!(DiemSystem::validator_set_size() == 4, 7357000180201);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357000180202);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357000180203);
        assert!(
            DiemSystem::is_validator(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B) == false, 
            7357000180204
        );

        // Mock everyone being a CASE 1
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);

        TowerState::test_helper_mock_mining_vm(vm, @Alice, 20);
        TowerState::test_helper_mock_mining_vm(vm, @Bob, 20);
        TowerState::test_helper_mock_mining_vm(vm, @Carol, 20);
        TowerState::test_helper_mock_mining_vm(vm, @Dave, 20);
        TowerState::test_helper_mock_mining_vm(vm, @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 20);

        // enable autopay and transfer coins to the new operator
        let new_val = DiemAccount::test_helper_create_signer(
            vm, @0x3DC18D1CF61FAAC6AC70E3A63F062E4B
        );
        AutoPay::enable_autopay(&new_val);
        let new_oper = ValidatorConfig::get_operator(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B);
        DiemAccount::vm_make_payment_no_limit<GAS>(
            @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, new_oper, 60009, x"", x"", vm
        );

        // check the new account is in the list of eligible
        let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(vm));
        assert!(len == 5 , 7357000180205);

        // Adding eve to validator universe - would be done by self
        ValidatorUniverse::test_helper_add_self_onboard(vm, @0x3DC18D1CF61FAAC6AC70E3A63F062E4B);

        let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(vm));
        assert!(len == 6 , 7357000180206);

        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };

        EpochBoundary::reconfigure(vm, 15); // reconfigure at height 15
    }
}
// check: EXECUTED

// Epoch 3 began
// The new node is in validatorUniverse and also in validator set

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;
    fun main(vm: signer) {
        // Tests on initial size of validators
        assert!(DiemSystem::validator_set_size() == 6, 7357000200301);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357000200302);
        assert!(DiemSystem::is_validator(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B), 7357000200303);
        let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(&vm));
        assert!(len == 6, 7357000200304);
      }
}
// check: EXECUTED
