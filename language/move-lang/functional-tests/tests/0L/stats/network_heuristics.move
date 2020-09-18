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
        Stats::insert_voter_list(account, 1, &validators);
        Vector::push_back<address>(&mut validators, {{bob}});
        Stats::insert_voter_list(account, 2, &validators);
        Vector::push_back<address>(&mut validators, {{charlie}});
        Stats::insert_voter_list(account, 3, &validators);
        Stats::insert_voter_list(account, 4, &validators);
        Vector::pop_back<address>(&mut validators);
        Stats::insert_voter_list(account, 5, &validators);
        Vector::remove(&mut validators, 0);
        Stats::insert_voter_list(account, 6, &validators);
        Stats::insert_voter_list(account, 7, &validators);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: libraroot
script{
    use 0x1::Stats;
    fun main(){
        // Verify that the insets actually happened by querying the data struct.
        let a = Stats::network_heuristics(3, 4);
        assert(a == 3, 1);
        a = Stats::network_heuristics(0, 3);
        assert(a == 0, 2);
        a = Stats::network_heuristics(5, 5);
        assert(a == 2, 3);
        a = Stats::network_heuristics(6, 7);
        assert(a == 1, 4);
    }
}
// check: EXECUTED
