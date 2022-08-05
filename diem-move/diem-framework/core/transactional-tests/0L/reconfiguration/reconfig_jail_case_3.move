//# init --validators Alice Bob Carol Dave Eve Frank

// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 1
// FRANK is CASE 3

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    use DiemFramework::Mock;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {
        Mock::mock_case_1(&vm, @Alice, 0, 15);
        Mock::mock_case_1(&vm, @Bob, 0, 15);
        Mock::mock_case_1(&vm, @Carol, 0, 15);
        Mock::mock_case_1(&vm, @Dave, 0, 15);
        Mock::mock_case_1(&vm, @Eve, 0, 15);

        /// Frank will mine, but not sign

        TowerState::test_helper_mock_mining_vm(&vm, @Frank, 20);

        assert!(DiemSystem::validator_set_size() == 6, 7357008005003);
        // assert!(DiemSystem::is_validator(@Alice) == true, 7357008005004);
    }
}

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    use DiemFramework::Debug::print;

    fun main() {
        // We are in a new epoch.
        assert!(DiemConfig::get_current_epoch() == 2, 7357008009008);
        // Tests on initial size of validators 
        print(&DiemSystem::validator_set_size());
        assert!(DiemSystem::validator_set_size() == 5, 7357008009009);
        assert!(DiemSystem::is_validator(@Frank) == false, 7357008009010);
    }
}