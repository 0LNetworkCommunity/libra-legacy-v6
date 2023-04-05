//# init --validators Alice Bob Carol Dave Eve Frank
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 4000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator
//! account: frank, 1000000, 0, validator

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::ValidatorConfig;
  use DiemFramework::TestFixtures;
  use DiemFramework::VDF;
  use DiemFramework::Vouch;
  use Std::Vector;

  fun main(vm: signer, sender: signer) {
    // Scenario: Alice, an existing validator, is sending a transaction for Eve, 
    // with a challenge and proof from eve's block_0
    let challenge = TestFixtures::eve_0_easy_chal();
    let solution = TestFixtures::eve_0_easy_sol();
    // // Parse key and check
    let (new_addr, _auth_key) = VDF::extract_address_from_challenge(&challenge);
    assert!(new_addr == @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, 401);

    // let epochs_since_creation = 10;

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
    assert!(ValidatorConfig::is_valid(new_addr), 7357130101031000);

    let vouchers = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut vouchers, @Bob);
    Vector::push_back(&mut vouchers, @Carol);
    Vector::push_back(&mut vouchers, @Dave);

    Vouch::vm_migrate(&vm, @0x3DC18D1CF61FAAC6AC70E3A63F062E4B, vouchers);        

  }
}



// The new node starts mining and submiting proofs in the epoch 2
//
//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::EpochBoundary;
    use DiemFramework::Mock;
    use Std::Vector;
    use DiemFramework::ValidatorUniverse;

    fun main(vm: signer, _: signer) {
        let vm = &vm;
        // Tests on initial size of validators
        assert!(DiemSystem::validator_set_size() == 6, 7357000180201);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357000180202);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357000180203);
        assert!(
            DiemSystem::is_validator(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B) == false, 
            7357000180204
        );


        let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators());
        assert!(len == 7 , 7357000180206);

        
        // all validators ar compliant
        Mock::all_good_validators(vm);
        // all place bids
        Mock::pof_default(vm);
        // trigger epoch
        EpochBoundary::reconfigure(vm, 15); // reconfigure at height 15
    }
}

// Epoch 3 began
// The new node is in validatorUniverse and also in validator set

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;
    // use DiemFramework::Debug::print;

    fun main() {
        // Tests on initial size of validators
        // print(&DiemSystem::validator_set_size());
        assert!(DiemSystem::validator_set_size() == 7, 7357000200301);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357000200302);
        assert!(
            DiemSystem::is_validator(@0x3DC18D1CF61FAAC6AC70E3A63F062E4B),
            7357000200303
        );
        let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators());
        assert!(len == 7, 7357000200304);
      }
}