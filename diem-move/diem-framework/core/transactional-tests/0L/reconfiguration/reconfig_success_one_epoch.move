//# init --validators Alice Bob Carol Dave Eve

// Happy case: All validators from genesis are compliant
// and place sucessful bids for the next set.
// we get to a new epoch.
// Note: we are also testing the test runner syntax for advancing to new epoch.

// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail with Staging and Production Constants, only for Debug - due to epoch length.

//# block --proposer Alice --time 1 --round 0

//! NewBlockEvent

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::Mock;

    fun main(vm: signer, _: signer) {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008012001);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008012002);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357008012003);

        // all validators compliant
        Mock::all_good_validators(&vm);
        // all validators bid
        Mock::pof_default(&vm);

    }
}
// check: EXECUTED


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
        assert!(DiemSystem::validator_set_size() == 5, 7357008012007);
        assert!(DiemConfig::get_current_epoch() == 2, 7357008012008);
    }
}
// check: EXECUTED