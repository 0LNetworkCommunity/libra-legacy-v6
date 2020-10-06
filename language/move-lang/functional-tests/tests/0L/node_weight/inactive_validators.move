//! account: alice, 8, 0, validator
//! account: bob, 7, 0, validator
//! account: carol, 6, 0, validator
//! account: sha, 9, 0, validator
//! account: hola, 10, 0, validator

// In this test there are 5 validators, they will be added to ValidatorUniverse
// We will mock the Stats so that only one active validator {{alice}} is present
// Irrespective of n, we get only one validator- alice

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;
    use 0x0::ValidatorUniverse;
    use 0x0::Stats;

    // n is less than vector length. We need top N.
    // Top 1 account test. N=1 vector has 5 addresses
    fun main(account: &signer) {
        // check the count of validators we have in the Universe.
        let vec =  ValidatorUniverse::get_eligible_validators(account);
        Transaction::assert(Vector::length<address>(&vec) == 5, 7357000140101);

        // We will mock a voter lists where only Alice is successfully signing blocks
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{alice}});

        let i = 1;
        while (i < 13) {
            // Mock the validator doing work for 12 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };

        // get the list of top n=1 accounts, for height 12.
        let result = NodeWeight::top_n_accounts(account, 1, 12);
        // should only have one item in list
        Transaction::assert(Vector::length<address>(&result) == 1, 7357000140102);
        // the item should be Alice's account.
        Transaction::assert(Vector::contains<address>(&result, &{{alice}}) == true, 7357000140103);
    }
}
// check: EXECUTED



//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;


    // Now lets check if the results are the smae even in a larger N, N=4.
    // Again we should only see Alice returned in the set. Since she is the only one doing work.
    fun main(account: &signer) {
        let result = NodeWeight::top_n_accounts(account, 4, 12);
        Transaction::assert(Vector::length<address>(&result) == 1, 6);
        Transaction::assert(Vector::contains<address>(&result, &{{alice}}) == true, 7);
    }
}
// check: EXECUTED