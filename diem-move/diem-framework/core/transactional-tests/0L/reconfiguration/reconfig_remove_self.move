//# init --validators Alice Bob Carol

// Testing if CAROL can successfully remove herself as a validator

// CAROL will remove herself as a validator

//# block --proposer Alice --time 1 --round 0

//! NewBlockEvent

// Carol removes herself as a validator
//# run --admin-script --signers DiemRoot Carol
stdlib_script::ValidatorScripts::leave
// check: "Keep(EXECUTED)"

//# run --admin-script --signers DiemRoot DiemRoot
script {
    // use DiemFramework::TowerState;
    use DiemFramework::Stats;
    use Std::Vector;
    // use DiemFramework::EpochBoundary;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {
        // todo: change name to Mock epochs
        // TowerState::test_helper_set_epochs(&sender, 5);
        let voters = Vector::singleton<address>(@Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
        // Carol is still a validator until the next epoch
        assert!(DiemSystem::validator_set_size() == 3, 7357008011001);
        assert!(DiemSystem::is_validator(@Alice), 7357008011002);
        assert!(DiemSystem::is_validator(@Bob), 7357008011003);
        assert!(DiemSystem::is_validator(@Carol), 7357008011004);
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
        assert!(DiemConfig::get_current_epoch() == 2, 7357008011005);
        // Tests to ensure validator set size has indeed dropped
        assert!(DiemSystem::validator_set_size() == 2, 7357008011006);
        // Carol is no longer a validator because she removed herself the previous epoch
        assert!(DiemSystem::is_validator(@Carol) == false, 7357008011007);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    // use DiemFramework::EpochBoundary;
    use Std::Vector;
    use DiemFramework::Stats;
    
    fun main(vm: signer, _: signer) {
        // start a new epoch.
        let voters = Vector::singleton<address>(@Alice);
        Vector::push_back<address>(&mut voters, @Bob);

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
    }
}
//check: EXECUTED

///////////////////////////////

///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//# block --proposer Alice --time 122000000 --round 30

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    fun main() {
        assert!(DiemConfig::get_current_epoch() == 3, 7357008011008);

        // carol is still not a validator because she has not rejoined. 
        assert!(!DiemSystem::is_validator(@Carol), 7357008011009);
    }
}
//check: EXECUTED



//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TowerState;
    // use DiemFramework::DiemConfig;
    fun main(_dr: signer, sender: signer) {
        // Mock some mining so carol can send rejoin tx
        TowerState::test_helper_mock_mining(&sender, 100);
    }
}

// Carol SENDS JOIN TX to rejoin validator set. 

//# run --admin-script --signers DiemRoot Carol
stdlib_script::ValidatorScripts::join
// check: "Keep(EXECUTED)"


///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//# block --proposer Alice --time 183000000 --round 45

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    fun main() {
        assert!(DiemConfig::get_current_epoch() == 4, 7357008011010);

        // Carol is a validator once more
        assert!(DiemSystem::is_validator(@Carol), 7357008011011);
        assert!(DiemSystem::validator_set_size() == 3, 7357008011012);
    }
}
//check: EXECUTED



