script {
    use 0x1::ValidatorUniverse;
    use 0x1::Signer;
    fun remove_self(validator: &signer) {
        let addr = Signer::address_of(validator);
        if (ValidatorUniverse::is_in_universe(addr)) {
            ValidatorUniverse::remove_self(validator);
        };
    }
}
