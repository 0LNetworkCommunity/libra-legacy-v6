//! account: alice, 1000000, 0, validator
// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: alice
script {
    use 0x0::PersistenceTrial;
    use 0x0::Transaction;
    fun main(){
      PersistenceTrial::initialize();

        PersistenceTrial::add_stuff();
        Transaction::assert(PersistenceTrial::length() == 3, 0);
        Transaction::assert(PersistenceTrial::contains(1), 1);
    }
}
// check: EXECUTED
