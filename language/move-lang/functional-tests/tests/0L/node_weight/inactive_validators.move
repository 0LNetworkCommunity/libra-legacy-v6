//! account: dummy-prevents-genesis-reload, 5, 0, validator

//! account: alice, 8, 0, validator
//! account: bob, 7
//! account: carol, 6
//! account: sha, 9
//! account: hola, 10

// Only one active validator is present
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

        ValidatorUniverse::add_validator({{alice}});
        ValidatorUniverse::add_validator({{bob}});
        ValidatorUniverse::add_validator({{carol}});
        ValidatorUniverse::add_validator({{sha}});
        ValidatorUniverse::add_validator({{hola}});

        let vec =  ValidatorUniverse::get_eligible_validators(account);
        Transaction::assert(Vector::length<address>(&vec) == 6, 5);

        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, {{alice}});
        Stats::insert_voter_list(1, &validators);
        Stats::insert_voter_list(2, &validators);
        Stats::insert_voter_list(3, &validators);
        Stats::insert_voter_list(4, &validators);
        Stats::insert_voter_list(5, &validators);
        Stats::insert_voter_list(6, &validators);
        Stats::insert_voter_list(7, &validators);
        Stats::insert_voter_list(8, &validators);
        Stats::insert_voter_list(9, &validators);
        Stats::insert_voter_list(10, &validators);
        Stats::insert_voter_list(11, &validators);
        Stats::insert_voter_list(12, &validators);

        let result = NodeWeight::top_n_accounts(account,1, 12);
        Transaction::assert(Vector::length<address>(&result) == 1, 6);
        Transaction::assert(Vector::contains<address>(&result, &{{alice}}) == true, 7);
    }
}
// check: EXECUTED



//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;

    // n is less than vector length. We need top N.
    // Top 1 account test. N=1 vector has 5 addresses
    fun main(account: &signer) {
        let result = NodeWeight::top_n_accounts(account,4, 12);
        Transaction::assert(Vector::length<address>(&result) == 1, 6);
        Transaction::assert(Vector::contains<address>(&result, &{{alice}}) == true, 7);
    }
}
// check: EXECUTED