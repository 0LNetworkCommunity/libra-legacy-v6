//! account: alice, 1000000, 0, validator

// Tests the prologue reconfigures based on wall clock

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
    fun main(){
      // the new epoch has reset the timer.
      assert(!Reconfigure::epoch_finished(), 735701);
    }
}
// check: EXECUTED