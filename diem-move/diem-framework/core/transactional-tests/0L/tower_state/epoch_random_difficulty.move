//# init --validators Alice Bob Carol Dave

//# block --proposer Alice --time 1 --round 1

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;

    fun main() {
        let (diff, sec) = TowerState::get_difficulty();
        // check the state started with the testnet defaults
        assert!(diff==100, 735701);
        assert!(sec==512, 735702);
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
    use DiemFramework::TowerState;
    // use DiemFramework::Debug::print;

    fun main() {
        let (diff, sec) = TowerState::get_difficulty();
        // print(&diff);
        // check the state started with the testnet defaults
        assert!(diff==332, 735703);
        assert!(sec==512, 735704);

    }
}