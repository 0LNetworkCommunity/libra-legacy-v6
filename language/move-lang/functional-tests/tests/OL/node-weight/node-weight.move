//! account: alice, 8
//! account: bob, 7
//! account: carol, 6
//! account: sha, 9
//! account: hola, 10


//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;
    use 0x0::ValidatorUniverse;
    // Base Case: If n is greater than or equal to vector length, return vector itself    
    // Test that length is the same. 
    // N equal to vector length       
    fun main(account: &signer) {
        let vec = Vector::empty();

        Vector::push_back<address>(&mut vec, {{alice}});
        ValidatorUniverse::add_validator({{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        ValidatorUniverse::add_validator({{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        ValidatorUniverse::add_validator({{carol}});
        Vector::push_back<address>(&mut vec, {{sha}});
        ValidatorUniverse::add_validator({{sha}});
        Vector::push_back<address>(&mut vec, {{hola}});
        ValidatorUniverse::add_validator({{hola}});

        let (equals_test, total_voting_power) = NodeWeight::top_n_accounts(account,5);
        Transaction::assert(total_voting_power == 0, 1);
        Transaction::assert(Vector::length<address>(&equals_test) == 5, 2);
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
    // Base Case: If n is greater than or equal to vector length, return vector itself    
    // N greater than the vector length
    fun main(account: &signer) {
        let vec = Vector::empty();

        Vector::push_back<address>(&mut vec, {{alice}});
        ValidatorUniverse::add_validator({{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        ValidatorUniverse::add_validator({{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        ValidatorUniverse::add_validator({{carol}});
        Vector::push_back<address>(&mut vec, {{sha}});
        ValidatorUniverse::add_validator({{sha}});
        Vector::push_back<address>(&mut vec, {{hola}});
        ValidatorUniverse::add_validator({{hola}});
         
        let (equals_test, total_voting_power) = NodeWeight::top_n_accounts(account,5);
        Transaction::assert(total_voting_power == 0, 1);
        Transaction::assert(Vector::length<address>(&equals_test) == 5, 2);
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

    // n is less than vector length. We need top N.   
    // Top 1 account test. N=1 vector has 5 addresses
    fun main(account: &signer) {
        let vec = Vector::empty();

        Vector::push_back<address>(&mut vec, {{alice}});
        ValidatorUniverse::add_validator({{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        ValidatorUniverse::add_validator({{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        ValidatorUniverse::add_validator({{carol}});
        Vector::push_back<address>(&mut vec, {{sha}});
        ValidatorUniverse::add_validator({{sha}});
        Vector::push_back<address>(&mut vec, {{hola}});
        ValidatorUniverse::add_validator({{hola}});

        let (result, total_voting_power) = NodeWeight::top_n_accounts(account,1);
        Transaction::assert(Vector::length<address>(&result) == 1, 1);
        Transaction::assert(total_voting_power == 0, 2);
        Transaction::assert(Vector::contains<address>(&result, &{{hola}}) == true, 3);
            
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

    // n is less than vector length. We need top N.   
    // Top 3 account test. N=3 vector has 5 addresses
    fun main(account: &signer) {
        let vec = Vector::empty();

        Vector::push_back<address>(&mut vec, {{alice}});
        ValidatorUniverse::add_validator({{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        ValidatorUniverse::add_validator({{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        ValidatorUniverse::add_validator({{carol}});
        Vector::push_back<address>(&mut vec, {{sha}});
        ValidatorUniverse::add_validator({{sha}});
        Vector::push_back<address>(&mut vec, {{hola}});
        ValidatorUniverse::add_validator({{hola}});

        let (result, total_voting_power) = NodeWeight::top_n_accounts(account,3);
        Transaction::assert(Vector::length<address>(&result) == 3, 1);
        Transaction::assert(total_voting_power == 0, 2);
    }
}
// check: EXECUTED