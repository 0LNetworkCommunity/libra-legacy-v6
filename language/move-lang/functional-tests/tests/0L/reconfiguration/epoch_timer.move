//! account: alice, 1000000, 0, validator

// Tests the prologue reconfigures based on wall clock

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
    use 0x1::Epoch;
    use 0x1::DiemTimestamp;
    
    fun main(){
      // the new epoch has reset the timer.
      assert(DiemTimestamp::now_seconds() == 61, 7357008002001);
      assert(!Epoch::epoch_finished(100), 7357008002002);
    }
}
// check: EXECUTED
