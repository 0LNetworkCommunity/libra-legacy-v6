//! account: alice, 1000000, 0, validator
// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: association

script {
    use 0x0::AltStats;
    use 0x0::Transaction;

    fun main(_sender: &signer){
      // Checks that altstats was initialized in genesis for Alice.

      // AltStats::initialize();

      AltStats::insert_proposer({{alice}});
      Transaction::assert(AltStats::length() == 3, 0);
      Transaction::assert(AltStats::contains(1), 1);
    }
}
// check: EXECUTED
