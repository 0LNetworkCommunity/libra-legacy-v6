script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::Vector;
    use 0x0::ValidatorUniverse;
    fun main(account: &signer, alice: address, bob: address, carol: address,
        sha: address, _ram: address) {
        // Create vector of validators and add the desired new validator set
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, alice);
        ValidatorUniverse::add_validator(alice);
        Vector::push_back<address>(&mut vec, bob);
        ValidatorUniverse::add_validator(bob);
        Vector::push_back<address>(&mut vec, carol);
        ValidatorUniverse::add_validator(carol);
        Transaction::assert(Vector::length<address>(&vec) == 3, 5);

        // Update the validator set
        LibraSystem::bulk_update_validators(account, vec, 15, 20);

        // Assert that updates happened correctly
        Transaction::assert(LibraSystem::validator_set_size() == 3, 6);
        Transaction::assert(LibraSystem::is_validator(sha) == false, 7);
        Transaction::assert(LibraSystem::is_validator(bob) == true, 8);
    }
}
