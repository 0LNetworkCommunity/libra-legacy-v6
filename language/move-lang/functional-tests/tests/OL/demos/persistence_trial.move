//! account: alice, 1000000, 0, empty
//! account: bob, 1000000, 0, empty

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: alice
script {
use 0x0::PersistenceTrial;
    fun main() {
        PersistenceTrial::initialize();
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x0::PersistenceTrial;
    use 0x0::Transaction;
    fun main(){
        PersistenceTrial::add_stuff();
        Transaction::assert(PersistenceTrial::length() == 3, 0);
        Transaction::assert(PersistenceTrial::contains(1), 1);
        Transaction::assert(PersistenceTrial::contains(2), 2);
        Transaction::assert(PersistenceTrial::contains(3), 3);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x0::PersistenceTrial;
    use 0x0::Transaction;
    fun main(){
        Transaction::assert(PersistenceTrial::length() == 2, 4);
    }
}
// check: ABORTED

//! new-transaction
//! sender: alice
script {
    use 0x0::PersistenceTrial;
    use 0x0::Transaction;
    fun main(){
        PersistenceTrial::remove_stuff();
        Transaction::assert(PersistenceTrial::isEmpty(), 5);
    }
}
// check: EXECUTED

// this will fail because bob does not have the data struct
//! new-transaction
//! sender: bob
script {
    use 0x0::PersistenceTrial;
    fun main(){
        PersistenceTrial::add_stuff();
    }
}
// check: Failure
