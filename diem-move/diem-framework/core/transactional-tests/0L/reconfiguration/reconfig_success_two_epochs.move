//# init --validators Alice Bob Carol Dave Eve Frank

// This test is to check if two epochs succesfully happen with all 
// validators being CASE 1.

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::Mock;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {

        assert!(DiemSystem::validator_set_size() == 6, 7357008013007);
        // all validators compliant
        Mock::all_good_validators(&vm);
        // all validators bid
        Mock::pof_default(&vm);


        // need to also mock network fees being paid.
        Mock::mock_network_fees(&vm, 4000000);
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
    use DiemFramework::Mock;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {

        assert!(DiemSystem::validator_set_size() == 6, 7357008013007);
        // all validators compliant
        Mock::all_good_validators(&vm);
        // all validators bid
        Mock::pof_default(&vm);
    }
}
// check: EXECUTED

///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//# block --proposer Alice --time 122000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////



//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;

    fun main() {
        assert!(DiemSystem::validator_set_size() == 6, 73570080130014);
        assert!(DiemConfig::get_current_epoch() == 3, 7357008013015);
    }
}
// check: EXECUTED