//! account: alice, 1000000, 0, validator
// The data will be initialized and operated all through alice's account

//! block-prologue
//! proposer: alice
//! block-time: 0

//! new-transaction
//! sender: alice

script {
    // use 0x1::PersistenceDemo;
    use 0x1::LibraTimestamp;
    use 0x1::EpochTimer;
    use 0x1::Debug::print;
    fun main(){
      print(&EpochTimer::epoch_finished());
      print(&LibraTimestamp::now_seconds());

      // assert(LibraTimestamp::now_seconds() == 10, 735701);
    }
}
// check: EXECUTED