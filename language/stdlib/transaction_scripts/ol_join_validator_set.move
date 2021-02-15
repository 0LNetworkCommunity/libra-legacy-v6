script {
    use 0x1::ValidatorUniverse;
    use 0x1::Signer;
    use 0x1::MinerState;
    fun join(validator: &signer) {
        let addr = Signer::address_of(validator);
        // if is above threshold continue, or raise error.
        assert(MinerState::node_above_thresh(validator, addr), 01);
        // if is not in universe, add back
        if (!ValidatorUniverse::is_in_universe(addr)) {
            ValidatorUniverse::add_self(validator);
        };
        // if is jailed, try to unjail
        if (ValidatorUniverse::is_jailed(addr)) {
            ValidatorUniverse::unjail_self(validator);
        };
    }
}
