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
        Stats::insert_voter_list(1, &validators);
        Vector::push_back<address>(&mut validators, {{bob}});
        Stats::insert_voter_list(2, &validators);
        Vector::push_back<address>(&mut validators, {{charlie}});
        Stats::insert_voter_list(3, &validators);
        Stats::insert_voter_list(4, &validators);
        Vector::pop_back<address>(&mut validators);
        Stats::insert_voter_list(5, &validators);
        Vector::remove(&mut validators, 0);
        Stats::insert_voter_list(6, &validators);
        Stats::insert_voter_list(7, &validators);
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
        let a = Stats::node_heuristics({{alice}}, 0, 3);
        Transaction::assert(a == 3, 1);
        a = Stats::node_heuristics({{alice}}, 0, 10);
        Transaction::assert(a == 5, 1);
        a = Stats::node_heuristics({{bob}}, 0, 5);
        Transaction::assert(a == 4, 1);
        a = Stats::node_heuristics({{bob}}, 3, 100);
        Transaction::assert(a == 5, 1);
        a = Stats::node_heuristics({{charlie}}, 0, 50);
        Transaction::assert(a == 2, 1);
        a = Stats::node_heuristics({{charlie}}, 0, 3);
        Transaction::assert(a == 1, 1);

        // Network Heuristics Tests
        a = Stats::network_heuristics(3, 4);
        Transaction::assert(a == 3, 1);
        a = Stats::network_heuristics(0, 3);
        Transaction::assert(a == 0, 1);
        a = Stats::network_heuristics(5, 5);
        Transaction::assert(a == 2, 1);
        a = Stats::network_heuristics(6, 7);
        Transaction::assert(a == 1, 1);
    }
}
// check: EXECUTED
