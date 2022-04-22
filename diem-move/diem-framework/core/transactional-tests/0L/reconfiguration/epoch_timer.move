//# init --validators Alice

// Tests the prologue reconfigures based on wall clock

//! block-prologue
//! proposer: alice
//! block-time: 1
//! round: 1


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: diemroot

script {
    use DiemFramework::Epoch;
    use DiemFramework::DiemTimestamp;
    
    fun main(){
      // the new epoch has reset the timer.
      assert!(DiemTimestamp::now_seconds() == 61, 7357008002001);
      assert!(!Epoch::epoch_finished(), 7357008002002);
    }
}
// check: EXECUTED