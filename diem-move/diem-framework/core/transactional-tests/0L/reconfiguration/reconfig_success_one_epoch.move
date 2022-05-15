//# init --validators Alice Bob Carol Dave Eve

// Case 1: Validators are compliant. 
// This test is to check if validators are present after the first epoch.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail with Staging and Production Constants, only for Debug - due to epoch length.

//# block --proposer Alice --time 1 --round 0

//! NewBlockEvent

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;

    fun main() {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008012001);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008012002);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357008012003);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;

    fun main() {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008012004);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008012005);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357008012006);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::Stats;

    // This is the the epoch boundary.
    fun main(vm: signer, _: signer) {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        Vector::push_back<address>(&mut voters, @Eve);

        // Overwrite the statistics to mock that all have been validating.
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
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
        assert!(DiemSystem::validator_set_size() == 5, 7357008012007);
        assert!(DiemConfig::get_current_epoch() == 2, 7357008012008);
    }
}
// check: EXECUTED