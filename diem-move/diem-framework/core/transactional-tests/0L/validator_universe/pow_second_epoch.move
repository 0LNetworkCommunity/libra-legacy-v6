// This test is to check if new epoch is triggered at end of 15 blocks.
// Here EPOCH-LENGTH = 15 Blocks.
// TO DO: Genesis function call to have 15 round epochs.
// NOTE: This test will fail in test-net and Production, only for Debug - due to epoch length.

//# init --validators Alice Bob
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator


//# run --admin-script --signers DiemRoot DiemRoot
script {
    
    use DiemFramework::DiemSystem;
    use DiemFramework::NodeWeight;
    fun main() {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 4, 7357220101011000);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357220101021000);
        assert!(NodeWeight::proof_of_weight(@Alice) == 0, 7357220101031000);

    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::Stats;

    fun main(vm: signer, _: signer) {
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
///// Trigger reconfiguration 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    
    use DiemFramework::DiemSystem;
    use DiemFramework::NodeWeight;
    fun main() {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 4, 7357220101041000);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357220101051000);
        //no mining was done by Alice.
        assert!(NodeWeight::proof_of_weight(@Alice) == 0, 7357220101061000);
    }
}
// check: EXECUTED
