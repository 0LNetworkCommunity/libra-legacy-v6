// Module to test bulk validator updates function in DiemSystem.move
//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator

// Test to check the current validator list . Then trigger update to the list 
// of validators, then re-run it. 
// This test is run with the function passing in the wrong current block on purpose.
// This avoids an error when a reconfig function happens before the first epoch 
// is completed.

//! new-transaction
//! sender: diemroot
script {
    
    use 0x1::DiemSystem;
    use 0x1::Vector;
    use 0x1::ValidatorUniverse;

    fun main(vm: signer) {
        // Tests on initial size of validators 
        assert(DiemSystem::validator_set_size() == 4, 73570080010001);
        assert(DiemSystem::is_validator(@{{alice}}), 73570080010002);
        assert(DiemSystem::is_validator(@{{bob}}), 73570080010003);
        assert(DiemSystem::is_validator(@{{carol}}), 73570080010004);
        assert(DiemSystem::is_validator(@{{dave}}), 73570080010005);

        let old_vec = ValidatorUniverse::get_eligible_validators(&vm);
        assert(Vector::length<address>(&old_vec) == 4, 73570080010006);
        
        //Create vector of validators and func call
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, @{{alice}});
        Vector::push_back<address>(&mut vec, @{{bob}});
        Vector::push_back<address>(&mut vec, @{{carol}});
        assert(Vector::length<address>(&vec) == 3, 73570080010007);

        DiemSystem::bulk_update_validators(&vm, vec);

        // Check if updates are done
        assert(DiemSystem::validator_set_size() == 3, 73570080010008);
        assert(DiemSystem::is_validator(@{{alice}}), 73570080010009);
        assert(DiemSystem::is_validator(@{{bob}}), 73570080010010);
        assert(DiemSystem::is_validator(@{{carol}}), 73570080010011);
        assert(DiemSystem::is_validator(@{{dave}}) == false, 73570080010012);
    }
}
// check: EXECUTED