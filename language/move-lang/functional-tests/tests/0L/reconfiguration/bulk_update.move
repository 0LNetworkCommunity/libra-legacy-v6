// Module to test bulk validator updates function in LibraSystem.move
//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator

// Test to check the current validator list . Then trigger update to the list of validators, then re-run it. 
// This test is run with the function passing in the wrong current block on purpose.
// This avoids an error when a reconfig function happens before the first epoch is completed

//! new-transaction
//! sender: diemroot
script {
    
    use 0x1::LibraSystem;
    use 0x1::Vector;
    use 0x1::ValidatorUniverse;

    fun main(vm: &signer) {
        // Tests on initial size of validators 
        assert(LibraSystem::validator_set_size() == 4, 73570001);
        assert(LibraSystem::is_validator({{alice}}), 73570002);
        assert(LibraSystem::is_validator({{bob}}), 73570003);
        assert(LibraSystem::is_validator({{carol}}), 73570004);
        assert(LibraSystem::is_validator({{dave}}), 73570005);

        let old_vec = ValidatorUniverse::get_eligible_validators(vm);
        assert(Vector::length<address>(&old_vec) == 4, 73570006);
        
        //Create vector of validators and func call
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, {{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        assert(Vector::length<address>(&vec) == 3, 73570007);

        LibraSystem::bulk_update_validators(vm, vec);

        // Check if updates are done
        assert(LibraSystem::validator_set_size() == 3, 73570008);
        assert(LibraSystem::is_validator({{alice}}), 73570009);
        assert(LibraSystem::is_validator({{bob}}), 73570010);
        assert(LibraSystem::is_validator({{carol}}), 73570011);
        assert(LibraSystem::is_validator({{dave}}) == false, 73570012);
    }
}
// check: EXECUTED