//! account: alice, 1000000, 0, validator
// The data will be initialized and operated all through alice's account

//! block-prologue
//! proposer: alice
//! block-time: 10000000

//! new-transaction
//! sender: alice

script {
    // use 0x1::PersistenceDemo;
    use 0x1::LibraTimestamp;
    use 0x1::EpochTimer;
    use 0x1::Debug::print;
    fun main(_sender: &signer){ // alice's signer type added in tx.
      // PersistenceDemo::initialize(sender);
      // PersistenceDemo::add_stuff(sender);
      // assert(PersistenceDemo::length(sender) == 3, 0);
      // assert(PersistenceDemo::contains(sender, 1), 1);
      print(&EpochTimer::is_up());
      assert(LibraTimestamp::now_microseconds() == 10000000, 77);
    }
}
// check: EXECUTED