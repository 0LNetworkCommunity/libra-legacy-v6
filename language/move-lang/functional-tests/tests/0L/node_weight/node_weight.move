//! account: alice, 8, 0, validator
//! account: bob, 7, 0, validator
//! account: carol, 6, 0, validator
//! account: sha, 9, 0, validator
//! account: hola, 10, 0, validator

// All nodes except hola voted in all rounds. 
// Hola votes in only two rounds 

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;
    use 0x0::ValidatorUniverse;
    use 0x0::Stats;

    fun main(account: &signer) {

        // Base Case: If validator universe vector length is less than the validator set size limit (N), return vector itself.
        // N equals to the vector length.

        //Check the size of the validator universe.
        let vec =  ValidatorUniverse::get_eligible_validators(account);
        Transaction::assert(Vector::length<address>(&vec) == 5, 7357000140101);


        // Everyone except Hola voted in rounds 1-10
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{sha}});
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{bob}});
        let i = 1;
        while (i < 11) {
            // Mock the validator doing work for 10 blocks, and stats being updated.
            Stats::insert_voter_list(i, &voters);
            i = i + 1;
        };

        // Adding Hola to the voters for rounds 11 and 12
        Vector::push_back<address>(&mut voters, {{hola}});
        Stats::insert_voter_list(11, &voters);
        Stats::insert_voter_list(12, &voters);

        // This is the base case: check case of the validator set limit being less than universe size.
        let top_n_is_under = NodeWeight::top_n_accounts(account, 3, 12);
        Transaction::assert(Vector::length<address>(&top_n_is_under) == 3, 7357000140102);

        // case of querying the full validator universe.
        let top_n_is_equal = NodeWeight::top_n_accounts(account, 5, 12);
        // One of the nodes did not vote, so they will be excluded from list.
        Transaction::assert(Vector::length<address>(&top_n_is_equal) == 4, 7357000140103);
        // Check Hola is not in that list.
        Transaction::assert(Vector::contains<address>(&top_n_is_equal, &{{hola}}) != true, 7357000140104);
        
        // case of querying a larger n than the validator universe.
        // Check if we ask for a larger set we also get 
        let top_n_is_over = NodeWeight::top_n_accounts(account, 9, 12);
        Transaction::assert(Vector::length<address>(&top_n_is_over) == 4, 7357000140105);

    }
}
// check: EXECUTED