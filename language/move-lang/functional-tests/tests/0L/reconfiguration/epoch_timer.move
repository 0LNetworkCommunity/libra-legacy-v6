//! account: alice, 1000000, 0, validator

// Tests the prologue reconfigures based on wall clock

//! block-prologue
//! proposer: alice
//! block-time: 1
//! round: 1


//////////////////////////////////////////////
///// Trigger reconfiguration at 2 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 2000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: libraroot

script {
    use 0x1::Reconfigure;
    use 0x1::LibraTimestamp;
    fun main(){
      // the new epoch has reset the timer.
      assert(LibraTimestamp::now_seconds() == 2, 735701);
      assert(!Reconfigure::epoch_finished(), 735702);
    }
}
// check: EXECUTED