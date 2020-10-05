//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000


//! new-transaction
//! sender: association
script {
    use 0x0::AltStats;
    use 0x0::Vector;
    fun main(){
        // Insert a bunch of data into the storage
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, {{alice}});
        AltStats::process_set_votes(&validators);
        Vector::push_back<address>(&mut validators, {{bob}});
        AltStats::process_set_votes(&validators);
        Vector::push_back<address>(&mut validators, {{charlie}});
        AltStats::process_set_votes(&validators);
        AltStats::process_set_votes(&validators);
        Vector::pop_back<address>(&mut validators);
        AltStats::process_set_votes(&validators);
        Vector::remove(&mut validators, 0);
        AltStats::process_set_votes(&validators);
        AltStats::process_set_votes(&validators);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: association
script{
    use 0x0::AltStats;
    use 0x0::Transaction;
    fun main(){
        // Verify that the insets actually happened by querying the data struct.
        let a = Stats::node_heuristics({{alice}}, 0, 3);
        Transaction::assert(a == 3, 1);
        a = Stats::node_heuristics({{alice}}, 0, 10);
        Transaction::assert(a == 5, 2);
        a = Stats::node_heuristics({{bob}}, 0, 5);
        Transaction::assert(a == 4, 3);
        a = Stats::node_heuristics({{bob}}, 3, 100);
        Transaction::assert(a == 5, 4);
        a = Stats::node_heuristics({{charlie}}, 0, 50);
        Transaction::assert(a == 2, 5);
        a = Stats::node_heuristics({{charlie}}, 0, 3);
        Transaction::assert(a == 1, 6);
    }
}
// check: EXECUTED
