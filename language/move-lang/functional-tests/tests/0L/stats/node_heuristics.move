//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000


//! new-transaction
//! sender: libraroot   
script {
    use 0x1::Stats;
    use 0x1::Vector;
    fun main(account: &signer){
        // Insert a bunch of data into the storage
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, {{alice}});
        Stats::insert_voter_list(account,1, &validators);
        Vector::push_back<address>(&mut validators, {{bob}});
        Stats::insert_voter_list(account,2, &validators);
        Vector::push_back<address>(&mut validators, {{charlie}});
        Stats::insert_voter_list(account,3, &validators);
        Stats::insert_voter_list(account,4, &validators);
        Vector::pop_back<address>(&mut validators);
        Stats::insert_voter_list(account,5, &validators);
        Vector::remove(&mut validators, 0);
        Stats::insert_voter_list(account,6, &validators);
        Stats::insert_voter_list(account,7, &validators);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: libraroot
script{
    use 0x1::Stats;
    fun main(){
        // Verify that the insets actually happened by querying the data struct.
        let a = Stats::node_heuristics({{alice}}, 0, 3);
        assert(a == 3, 1);
        a = Stats::node_heuristics({{alice}}, 0, 10);
        assert(a == 5, 2);
        a = Stats::node_heuristics({{bob}}, 0, 5);
        assert(a == 4, 3);
        a = Stats::node_heuristics({{bob}}, 3, 100);
        assert(a == 5, 4);
        a = Stats::node_heuristics({{charlie}}, 0, 50);
        assert(a == 2, 5);
        a = Stats::node_heuristics({{charlie}}, 0, 3);
        assert(a == 1, 6);
    }
}
// check: EXECUTED
