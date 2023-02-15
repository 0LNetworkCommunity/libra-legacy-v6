//# init --validators Alice Bob Carol Dave Eve Frank

// Testing if validator set remains the same if the size of eligible 
// validators falls below 4

// ALICE is CASE 1
// BOB is CASE 2
// CAROL is CASE 2
// DAVE is CASE 2
// EVE is CASE 3
// FRANK is CASE 2

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot DiemRoot
script {
    // use DiemFramework::Stats;
    use DiemFramework::Mock;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {
        Mock::mock_case_1(&vm, @Alice, 0, 15);
        Mock::mock_case_1(&vm, @Bob, 0, 15);
        Mock::mock_case_1(&vm, @Carol, 0, 15);
        Mock::mock_case_1(&vm, @Dave, 0, 15);
        Mock::mock_case_1(&vm, @Eve, 0, 15);
        Mock::mock_case_2(&vm, @Frank, 0, 15);

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
        assert!(DiemConfig::get_current_epoch() == 2, 7357008005005);
        print(&DiemSystem::validator_set_size());
        // Tests on initial size of validators
        assert!(DiemSystem::validator_set_size() == 6, 7357008005006);
    }
}