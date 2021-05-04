script {
    use 0x1::LibraSystem;
    use 0x1::Vector;
    
    // FOR E2E testing
    fun ol_reconfig_bulk_update_setup(account: &signer, alice: address, bob: address, carol: address,
        sha: address, ram: address) {

        
        // Create vector of desired validators
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, alice);
        Vector::push_back<address>(&mut vec, bob);
        Vector::push_back<address>(&mut vec, carol);
        Vector::push_back<address>(&mut vec, sha);
        Vector::push_back<address>(&mut vec, ram);
        assert(Vector::length<address>(&vec) == 5, 1);

        // Set this to be the validator set
        LibraSystem::bulk_update_validators(account, vec);

        // Tests on initial validator set
        assert(LibraSystem::validator_set_size() == 5, 2);
        assert(LibraSystem::is_validator(sha) == true, 3);
        assert(LibraSystem::is_validator(alice) == true, 4);
    }
}
