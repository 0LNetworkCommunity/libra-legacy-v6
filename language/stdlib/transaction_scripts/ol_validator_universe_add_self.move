script {
    use 0x1::ValidatorUniverse;
    use 0x1::Signer;
    use 0x1::MinerState;
    use 0x1::Errors;
    const NOT_ABOVE_THRESH: u64 = 220102;

    fun val_add_self(validator: &signer) {
        let addr = Signer::address_of(validator);
        // if is above threshold continue, or raise error.
        assert(MinerState::node_above_thresh(validator, addr), Errors::invalid_state(NOT_ABOVE_THRESH));
        // if is not in universe, add back
        if (!ValidatorUniverse::is_in_universe(addr)) {
            ValidatorUniverse::add_self(validator);
        };
    }
}
