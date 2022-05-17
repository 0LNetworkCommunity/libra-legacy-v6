// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 1
//! account: bob, 1000000, 0, validator
// CAROL is CASE 1
//! account: carol, 1000000, 0, validator
// DAVE is CASE 1
//! account: dave, 1000000, 0, validator
// EVE is CASE 1
//! account: eve, 1000000, 0, validator


// FRANK is CASE 3
//! account: frank, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    use 0x1::Mock;
    use 0x1::DiemSystem;

    fun main(vm: signer) {
        Mock::mock_case_1(&vm, @{{alice}}, 0, 15);
        Mock::mock_case_1(&vm, @{{bob}}, 0, 15);
        Mock::mock_case_1(&vm, @{{carol}}, 0, 15);
        Mock::mock_case_1(&vm, @{{dave}}, 0, 15);
        Mock::mock_case_1(&vm, @{{eve}}, 0, 15);

        /// Frank will mine, but not sign

        TowerState::test_helper_mock_mining_vm(&vm, @{{frank}}, 20);


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
        assert(DiemConfig::get_current_epoch() == 2, 7357008009008);
        // Tests on initial size of validators 
        print(&DiemSystem::validator_set_size());
        assert(DiemSystem::validator_set_size() == 5, 7357008009009);
        assert(DiemSystem::is_validator(@{{frank}}) == false, 7357008009010);
    }
}
//check: EXECUTED