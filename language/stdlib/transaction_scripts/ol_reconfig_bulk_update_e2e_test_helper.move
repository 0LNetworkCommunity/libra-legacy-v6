script {
    use 0x1::LibraSystem;
    use 0x1::Vector;
    use 0x1::ValidatorUniverse;
    use 0x1::Signer;
    fun ol_reconfig_bulk_update_e2e_test_helper(
        account: &signer,
        alice: &signer,
        bob: &signer,
        carol: &signer,
        dave: &signer,
    ) {
        // Create vector of validators and add the desired new validator set
        let vec = Vector::empty();
        ValidatorUniverse::add_validator(alice);
        ValidatorUniverse::add_validator(bob);
        ValidatorUniverse::add_validator(carol);

        Vector::push_back<address>(&mut vec, Signer::address_of(alice));
        Vector::push_back<address>(&mut vec, Signer::address_of(bob));
        Vector::push_back<address>(&mut vec, Signer::address_of(carol));
        
        assert(Vector::length<address>(&vec) == 3, 5);

        // Update the validator set
        LibraSystem::bulk_update_validators(account, vec);

        // Assert that updates happened correctly
        assert(LibraSystem::validator_set_size() == 3, 6);
        assert(LibraSystem::is_validator(Signer::address_of(dave)) == false, 7);
        assert(LibraSystem::is_validator(Signer::address_of(bob)) == true, 8);
    }
}
