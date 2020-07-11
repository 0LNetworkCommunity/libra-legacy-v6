script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::Vector;
    use 0x0::ValidatorUniverse;
    fun main(account: &signer, alice: address, bob: address, carol: address,
        sha: address, _ram: address) {
        // // Initialize the nodes as validators
        // ValidatorUniverse::add_validator(alice);
        // ValidatorUniverse::add_validator(bob);
        // ValidatorUniverse::add_validator(carol);
        // ValidatorUniverse::add_validator(sha);
        // ValidatorUniverse::add_validator(ram);

        // let vec = Vector::empty();
        // Vector::push_back<address>(&mut vec, alice);
        // Vector::push_back<address>(&mut vec, bob);
        // Vector::push_back<address>(&mut vec, carol);
        // Vector::push_back<address>(&mut vec, sha);
        // Vector::push_back<address>(&mut vec, ram);

        // LibraSystem::bulk_update_validators(account, vec, 15, 19);

        // Tests on initial size of validators
        // 15 because the e2e test framework is initialized with 10 validators
        Transaction::assert(LibraSystem::validator_set_size() == 15, 1000);
        Transaction::assert(LibraSystem::is_validator(sha) == true, 98);
        Transaction::assert(LibraSystem::is_validator(alice) == true, 98);

        //Create vector of validators and func call
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, alice);
        ValidatorUniverse::add_validator(alice);
        Vector::push_back<address>(&mut vec, bob);
        ValidatorUniverse::add_validator(bob);
        Vector::push_back<address>(&mut vec, carol);
        ValidatorUniverse::add_validator(carol);
        Transaction::assert(Vector::length<address>(&vec) == 3, 1);

        LibraSystem::bulk_update_validators(account, vec, 15, 20);

        // Check if updates are done
        Transaction::assert(LibraSystem::validator_set_size() == 3, 1000);
        Transaction::assert(LibraSystem::is_validator(sha) == false, 98);
        Transaction::assert(LibraSystem::is_validator(bob) == true, 98);
    }
}
