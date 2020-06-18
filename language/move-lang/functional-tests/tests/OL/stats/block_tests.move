//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000

//! new-transaction
//! sender: charlie
script {
    use 0x0::Transaction;
    fun main(){
        Transaction::assert(true, 1);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 2

//! new-transaction
//! sender: charlie
script {
    use 0x0::Transaction;
    fun main(){
        Transaction::assert(true, 1);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 4

//! new-transaction
//! sender: charlie
script {
    use 0x0::Transaction;
    fun main(){
        Transaction::assert(true, 1);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 6

//! new-transaction
//! sender: charlie
script {
    use 0x0::Transaction;
    fun main(){
        Transaction::assert(true, 1);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 8

//! new-transaction
//! sender: charlie
script {
    use 0x0::Transaction;
    fun main(){
        Transaction::assert(true, 1);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 10

//! new-transaction
//! sender: charlie
script {
    use 0x0::Transaction;
    fun main(){
        Transaction::assert(true, 1);
    }
}
// check: EXECUTED