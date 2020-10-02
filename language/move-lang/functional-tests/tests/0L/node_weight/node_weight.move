//! account: dummy-prevents-genesis-reload, 5, 0, validator

//! account: alice, 8, 0, validator
//! account: bob, 7
//! account: carol, 6
//! account: sha, 9
//! account: hola, 10

// All nodes except hola voted in all rounds. 
// Hola votes in only two rounds 
// dummy- ... does not participate in voting at all 

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;
    use 0x0::ValidatorUniverse;
    use 0x0::Stats;

    fun main(account: &signer) {

        // Base Case: If n is greater than or equal to validator universe vector length, return vector itself
        // N equals to the vector length

        ValidatorUniverse::add_validator({{alice}});
        ValidatorUniverse::add_validator({{bob}});
        ValidatorUniverse::add_validator({{carol}});
        ValidatorUniverse::add_validator({{sha}});
        ValidatorUniverse::add_validator({{hola}});

        let vec =  ValidatorUniverse::get_eligible_validators(account);
        Transaction::assert(Vector::length<address>(&vec) == 6, 8);

        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, {{sha}});
        Vector::push_back<address>(&mut validators, {{alice}});
        Vector::push_back<address>(&mut validators, {{carol}});
        Vector::push_back<address>(&mut validators, {{bob}});

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

        Vector::push_back<address>(&mut validators, {{hola}});
        Stats::insert_voter_list(11, &validators);
        Stats::insert_voter_list(12, &validators);


        let result = NodeWeight::top_n_accounts(account, 6, 12);
        // Two of the nodes did not vote
        Transaction::assert(Vector::length<address>(&result) == 4, 1);
        Transaction::assert(Vector::contains<address>(&result, &{{hola}}) != true,9);

    }
}
// check: EXECUTED

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;
    use 0x0::ValidatorUniverse;
    use 0x0::Stats;

    // Base Case: If n is greater than or equal to validator universe vector length, return vector itself
    // N greater than the vector length

    fun main(account: &signer) {

        let vec =  ValidatorUniverse::get_eligible_validators(account);
        Transaction::assert(Vector::length<address>(&vec) == 6, 3);


        let equals_test = NodeWeight::top_n_accounts(account, 9, 12);
        Transaction::assert(Vector::length<address>(&equals_test) == 4, 4);
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
    // Top 3 account test. N=3 vector has 5 addresses
    fun main(account: &signer) {
        let result = NodeWeight::top_n_accounts(account,3, 12);
        Transaction::assert(Vector::length<address>(&result) == 3, 1);
        Transaction::assert(Vector::contains<address>(&result, &{{hola}}) != true,9);
    }
}
// check: EXECUTED