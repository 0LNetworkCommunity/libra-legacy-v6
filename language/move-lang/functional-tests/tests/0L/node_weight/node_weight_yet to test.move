//! account: dummy-prevents-genesis-reload, 5, 0, validator

//! account: alice, 8
//! account: bob, 7
//! account: carol, 6
//! account: sha, 9
//! account: hola, 10


//! new-transaction
//! sender: libraroot
script {
    use 0x1::Vector;
    use 0x1::NodeWeight;
    use 0x1::ValidatorUniverse;

    // Base Case: If n is greater than or equal to validator universe vector length, return vector itself
    // Test that validator universe is less than  expected length 

    fun main(account: &signer) {
        let vec =  ValidatorUniverse::get_eligible_validators(account);
        assert(Vector::length<address>(&vec) == 1, 1);

        let list_of_addresses = NodeWeight::top_n_accounts(account,5);
        assert(Vector::length<address>(&list_of_addresses) == 1, 2);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: libraroot
script {
    use 0x1::Vector;
    use 0x1::NodeWeight;
    use 0x1::ValidatorUniverse;

    // Base Case: If n is greater than or equal to validator universe vector length, return vector itself
    // N greater than the vector length

    fun main(account: &signer) {
        ValidatorUniverse::add_validator({{alice}});
        ValidatorUniverse::add_validator({{bob}});
        ValidatorUniverse::add_validator({{carol}});
        ValidatorUniverse::add_validator({{sha}});
        ValidatorUniverse::add_validator({{hola}});
        
        let vec =  ValidatorUniverse::get_eligible_validators(account);
        assert(Vector::length<address>(&vec) == 6, 3);


        let equals_test = NodeWeight::top_n_accounts(account,6);
        assert(Vector::length<address>(&equals_test) == 6, 4);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: libraroot
script {
    use 0x1::Vector;
    use 0x1::NodeWeight;
    use 0x1::ValidatorUniverse;

    // n is less than vector length. We need top N.
    // Top 1 account test. N=1 vector has 5 addresses
    fun main(account: &signer) {
        let vec =  ValidatorUniverse::get_eligible_validators(account);
        assert(Vector::length<address>(&vec) == 6, 5);

        let result = NodeWeight::top_n_accounts(account,1);
        assert(Vector::length<address>(&result) == 1, 6);
        assert(Vector::contains<address>(&result, &{{hola}}) == true, 7);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: libraroot
script {
    use 0x1::Vector;
    use 0x1::NodeWeight;
    use 0x1::ValidatorUniverse;

    // n is less than vector length. We need top N.
    // Top 3 account test. N=3 vector has 5 addresses
    fun main(account: &signer) {
        let vec =  ValidatorUniverse::get_eligible_validators(account);
        assert(Vector::length<address>(&vec) == 6, 8);

        let result = NodeWeight::top_n_accounts(account,3);
        assert(Vector::length<address>(&result) == 3, 1);
        assert(Vector::contains<address>(&result, &{{hola}}) == true,9);
        assert(Vector::contains<address>(&result, &{{sha}}) == true, 10);
        // assert(Vector::contains<address>(&result, &{{alice}}) == true, 11);
        assert(Vector::contains<address>(&result, &{{carol}}) == true, 12);
        assert(Vector::contains<address>(&result, &{{bob}}) != true, 13);
    }
}
// check: EXECUTED