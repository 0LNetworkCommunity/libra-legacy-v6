//! account: alice, 1000000, 0, validator

// Tests the prologue reconfigures based on wall clock

//! block-prologue
//! proposer: alice
//! block-time: 10000000

//////////////////////////////////////////////
///// CHECKS RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: libraroot

script {
    // use 0x1::PersistenceDemo;
    use 0x1::LibraTimestamp;
    use 0x1::EpochTimer;
    use 0x1::Debug::print;
    fun main(){
      print(&EpochTimer::epoch_finished());
      print(&LibraTimestamp::now_seconds());

      // the new epoch has reset the timer.
      assert(!EpochTimer::epoch_finished(), 735701);
    }
}
// check: EXECUTED