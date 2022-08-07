// Testing if validator set remains the same if the size of eligible 
// validators falls below 4

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 2
//! account: bob, 1000000, 0, validator
// CAROL is CASE 2
//! account: carol, 1000000, 0, validator
// DAVE is CASE 2
//! account: dave, 1000000, 0, validator
// EVE is CASE 3
//! account: eve, 1000000, 0, validator
// FRANK is CASE 2
//! account: frank, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: diemroot
script {
    // use 0x1::Stats;
    use 0x1::Mock;
    use 0x1::DiemSystem;

    fun main(vm: signer) {
        Mock::mock_case_1(&vm, @{{alice}}, 0, 15);
        Mock::mock_case_1(&vm, @{{bob}}, 0, 15);
        Mock::mock_case_1(&vm, @{{carol}}, 0, 15);
        Mock::mock_case_1(&vm, @{{dave}}, 0, 15);
        Mock::mock_case_1(&vm, @{{eve}}, 0, 15);

        Mock::mock_case_2(&vm, @{{frank}}, 0, 15);


        assert(DiemSystem::validator_set_size() == 6, 7357008005003);
        // assert(DiemSystem::is_validator(@{{alice}}) == true, 7357008005004);
    }
}
//check: EXECUTED

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: diemroot
script {
    use 0x1::DiemSystem;
    use 0x1::DiemConfig;
    use 0x1::Debug::print;

    fun main(_account: signer) {
      
        // We are in a new epoch.
        assert(DiemConfig::get_current_epoch() == 2, 7357008005005);
        print(&DiemSystem::validator_set_size());
        // Tests on initial size of validators
        assert(DiemSystem::validator_set_size() == 6, 7357008005006);
    }
}
//check: EXECUTED
