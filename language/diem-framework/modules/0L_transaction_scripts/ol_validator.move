address 0x1 {
module ValidatorScripts {

    use 0x1::DiemSystem;
    use 0x1::Errors;
    use 0x1::TowerState;
    use 0x1::Signer;
    use 0x1::ValidatorUniverse;
    use 0x1::Vector;
    use 0x1::Jail;

    const NOT_ABOVE_THRESH_JOIN: u64 = 220101;
    const NOT_ABOVE_THRESH_ADD : u64 = 220102;
    const VAL_NOT_FOUND : u64 = 220103;
    const VAL_NOT_JAILED : u64 = 220104;

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
        assert(Vector::length<address>(&vec) == 5, 1);

        // Set this to be the validator set
        DiemSystem::bulk_update_validators(&account, vec);

        // Tests on initial validator set
        assert(DiemSystem::validator_set_size() == 5, 2);
        assert(DiemSystem::is_validator(sha) == true, 3);
        assert(DiemSystem::is_validator(alice) == true, 4);
    }

    public(script) fun self_unjail(validator: signer) {
        let addr = Signer::address_of(&validator);
        // if is above threshold continue, or raise error.
        assert(
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
        if (Jail::is_jailed(addr)) {
            Jail::self_unjail(&validator);
        };
    }

    public(script) fun voucher_unjail(voucher: signer, addr: address) {
        // if is above threshold continue, or raise error.
        assert(
            TowerState::node_above_thresh(addr), 
            Errors::invalid_state(NOT_ABOVE_THRESH_JOIN)
        );
        // if is not in universe, add back
        assert(
            TowerState::node_above_thresh(addr), 
            Errors::invalid_state(VAL_NOT_FOUND)
        );

        assert(
            TowerState::node_above_thresh(addr), 
            Errors::invalid_state(VAL_NOT_FOUND)
        );

        assert(
            Jail::is_jailed(addr), 
            Errors::invalid_state(VAL_NOT_JAILED)
        );
        // if is jailed, try to unjail
        Jail::vouch_unjail(&voucher, addr);
    }


    public(script) fun val_add_self(validator: signer) {
        let validator = &validator;
        let addr = Signer::address_of(validator);
        // if is above threshold continue, or raise error.
        assert(
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