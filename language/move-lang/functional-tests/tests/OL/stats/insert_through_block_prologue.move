//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000
//! account: storage, 4000000

//! new-transaction
//! gas-price: 1
//! max-gas: 2000000
//! sender: storage
script {
    use 0x0::Stats;
    use 0x0::Vector;
    fun main(){
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, {{alice}});
        Stats::newBlock(1, &validators);
        Vector::push_back<address>(&mut validators, {{bob}});
        Stats::newBlock(2, &validators);
        Vector::push_back<address>(&mut validators, {{charlie}});
        Stats::newBlock(3, &validators);
        Stats::newBlock(4, &validators);
        Vector::pop_back<address>(&mut validators);
        Stats::newBlock(5, &validators);
        Vector::remove(&mut validators, 0);
        Stats::newBlock(6, &validators);
        Stats::newBlock(7, &validators);
    }
}
// check: EXECUTED

// Verify that the insets actually happened by querying the data struct.
//! new-transaction
//! sender: storage
script{
    use 0x0::Stats;
    use 0x0::Transaction;
    fun main(){
        let a = Stats::Node_Heuristics({{alice}}, 0, 3);
        Transaction::assert(a == 3, 1);
        a = Stats::Node_Heuristics({{alice}}, 0, 10);
        Transaction::assert(a == 5, 1);
        a = Stats::Node_Heuristics({{bob}}, 0, 5);
        Transaction::assert(a == 4, 1);
        a = Stats::Node_Heuristics({{bob}}, 3, 100);
        Transaction::assert(a == 5, 1);
        a = Stats::Node_Heuristics({{charlie}}, 0, 50);
        Transaction::assert(a == 2, 1);
        a = Stats::Node_Heuristics({{charlie}}, 0, 3);
        Transaction::assert(a == 1, 1);

        // Network Heuristics Tests
        a = Stats::Network_Heuristics(3, 4);
        Transaction::assert(a == 3, 1);
        a = Stats::Network_Heuristics(0, 3);
        Transaction::assert(a == 0, 1);
        a = Stats::Network_Heuristics(5, 5);
        Transaction::assert(a == 2, 1);
        a = Stats::Network_Heuristics(6, 7);
        Transaction::assert(a == 1, 1);
    }
}
// check: EXECUTED