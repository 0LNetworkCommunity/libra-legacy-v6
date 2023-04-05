//# init --validators Alice

// Tests the prologue reconfigures based on wall clock

//# block --proposer Alice --time 1 --round 1

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::RecoveryMode;
    use Std::Vector;

    fun main(vm: signer, _: signer){
      RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      assert!(RecoveryMode::is_recovery(), 7357001);
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
    use DiemFramework::RecoveryMode;
    // use DiemFramework::Debug::print;

    fun main(){
      // RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      assert!(RecoveryMode::is_recovery(), 7357001);
      // print(&RecoveryMode::is_recovery());
    }
}

//////////////////////////////////////////////
///// Trigger second reconfiguration at 61*2 seconds ////
//# block --proposer Alice --time 122000000 --round 30

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::RecoveryMode;
    // // use DiemFramework::Debug::print;

    fun main(){
      // RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      assert!(!RecoveryMode::is_recovery(), 7357002);
      // // print(&RecoveryMode::is_recovery());
    }
}