//# init --validators Alice Bob Carol Dave

// This test is to check if validators are present after the first epoch.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail in test-net and Production, only for Debug - due to epoch length.

//# block --proposer Alice --time 1 --round 0

//! NewBlockEvent

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;

    fun main() {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 4, 7357008004001);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008004002);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;

    fun main() {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 4, 7357000180103);
    }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::Stats;

    fun main(vm: signer, _dr: signer) {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);

        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
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
    
    fun main() {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 4, 7357000180104);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357000180105);        
    }
}
//check: EXECUTED