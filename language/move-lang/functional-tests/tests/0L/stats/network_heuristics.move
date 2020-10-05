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
        let a = Stats::network_heuristics(3, 4);
        Transaction::assert(a == 3, 1);
        a = Stats::network_heuristics(0, 3);
        Transaction::assert(a == 0, 2);
        a = Stats::network_heuristics(5, 5);
        Transaction::assert(a == 2, 3);
        a = Stats::network_heuristics(6, 7);
        Transaction::assert(a == 1, 4);
    }
}
// check: EXECUTED
