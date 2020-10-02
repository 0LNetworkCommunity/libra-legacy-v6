script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::Vector;
    use 0x0::ValidatorUniverse;
    fun main(account: &signer, alice: address, bob: address, carol: address,
        sha: address, ram: address) {
        // Create vector of desired validators
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, alice);
        ValidatorUniverse::add_validator(alice);
        Vector::push_back<address>(&mut vec, bob);
        ValidatorUniverse::add_validator(bob);
        Vector::push_back<address>(&mut vec, carol);
        ValidatorUniverse::add_validator(carol);
        Vector::push_back<address>(&mut vec, sha);
        ValidatorUniverse::add_validator(sha);
        Vector::push_back<address>(&mut vec, ram);
        ValidatorUniverse::add_validator(ram);
        Transaction::assert(Vector::length<address>(&vec) == 5, 1);

        // Set this to be the validator set
        LibraSystem::bulk_update_validators(account, vec);

        // Tests on initial validator set
        Transaction::assert(LibraSystem::validator_set_size() == 5, 2);
        Transaction::assert(LibraSystem::is_validator(sha) == true, 3);
        Transaction::assert(LibraSystem::is_validator(alice) == true, 4);
    }
}
