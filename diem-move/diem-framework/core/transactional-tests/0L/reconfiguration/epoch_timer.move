//# init --validators Alice

// Tests the prologue reconfigures based on wall clock

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Epoch;
    use DiemFramework::DiemTimestamp;
    
    fun main(){
      // the new epoch has reset the timer.
      assert!(DiemTimestamp::now_seconds() == 61, 7357008002001);
      assert!(!Epoch::epoch_finished(100), 7357008002002);
    }
}
// check: EXECUTED