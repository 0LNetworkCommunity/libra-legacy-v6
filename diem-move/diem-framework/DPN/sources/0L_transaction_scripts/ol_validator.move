address DiemFramework {
module ValidatorScripts {

    use DiemFramework::DiemSystem;
    use Std::Errors;
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;

    const NOT_ABOVE_THRESH_JOIN: u64 = 220101;
    const NOT_ABOVE_THRESH_ADD : u64 = 220102;

    // FOR E2E testing
    public(script) fun ol_reconfig_bulk_update_setup(
        account: signer, alice: address, 
        bob: address, 
        carol: address,
        sha: address, 
        ram: address
    ) {
        // Create vector of desired validators
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, alice);
        Vector::push_back<address>(&mut vec, bob);
        Vector::push_back<address>(&mut vec, carol);
        Vector::push_back<address>(&mut vec, sha);
        Vector::push_back<address>(&mut vec, ram);
        assert!(Vector::length<address>(&vec) == 5, 1);

        // Set this to be the validator set
        DiemSystem::bulk_update_validators(&account, vec);

        // Tests on initial validator set
        assert!(DiemSystem::validator_set_size() == 5, 2);
        assert!(DiemSystem::is_validator(sha) == true, 3);
        assert!(DiemSystem::is_validator(alice) == true, 4);
    }

    public(script) fun join(validator: signer) {
        let addr = Signer::address_of(&validator);
        // if is above threshold continue, or raise error.
        assert!(
            TowerState::node_above_thresh(addr), 
            Errors::invalid_state(NOT_ABOVE_THRESH_JOIN)
        );
        // if is not in universe, add back
        if (!ValidatorUniverse::is_in_universe(addr)) {
            ValidatorUniverse::add_self(&validator);
        };
        // Initialize jailbit if not present
        if (!ValidatorUniverse::exists_jailedbit(addr)) {
            ValidatorUniverse::initialize(&validator);
        };

        // if is jailed, try to unjail
        if (ValidatorUniverse::is_jailed(addr)) {
            ValidatorUniverse::unjail_self(&validator);
        };
    }

    // public(script) fun leave(validator: signer) {
    //     let addr = Signer::address_of(&validator);
    //     if (ValidatorUniverse::is_in_universe(addr)) {
    //         ValidatorUniverse::remove_self(&validator);
    //     };
    // }

    public(script) fun val_add_self(validator: signer) {
        let validator = &validator;
        let addr = Signer::address_of(validator);
        // if is above threshold continue, or raise error.
        assert!(
            TowerState::node_above_thresh(addr), 
            Errors::invalid_state(NOT_ABOVE_THRESH_ADD)
        );
        // if is not in universe, add back
        if (!ValidatorUniverse::is_in_universe(addr)) {
            ValidatorUniverse::add_self(validator);
        };
    }    

}
}