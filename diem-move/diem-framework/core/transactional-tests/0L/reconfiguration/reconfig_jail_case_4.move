//# init --validators Alice Bob Carol Dave Eve Frank

// Scenario: All validators perform well except for Eve
// She is then jailed and dropped from the next epoch set.

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 4
// FRANK is CASE 1

//# block --proposer Alice --time 1 --round 0


//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::Mock;
    use DiemFramework::DiemSystem;
    use DiemFramework::Cases;

    fun main(vm: signer, _eve_sig: signer) {

        assert!(DiemSystem::validator_set_size() == 6, 7357008013007);
        // all validators compliant
        Mock::all_good_validators(&vm);
        // all validators bid
        Mock::pof_default(&vm);

        // now make Eve not compliant
        Mock::mock_case_4(&vm, @Eve, 0, 15);
        assert!(Cases::get_case(&vm, @Eve, 0, 15) == 4, 735701);
    }
}
//check: EXECUTED

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
    fun main() {
        // We are in a new epoch.
        assert!(DiemConfig::get_current_epoch() == 2, 7357008010008);
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008010009);
        assert!(DiemSystem::is_validator(@Eve) == false, 7357008010010);
    }
}
//check: EXECUTED