address 0x0 {

module Coin2 {
    // use 0x0::Association;
    use 0x0::FixedPoint32;
    use 0x0::Libra;
    use 0x0::Transaction;
    use 0x0::Signer;

    struct T { }

    public fun initialize(account: &signer): (Libra::MintCapability<T>, Libra::BurnCapability<T>) {
        //Association::assert_is_association(account);
        //0L Change
        Transaction::assert(Signer::address_of(account) == 0x0, 8001);
        // Register the Coin2 currency.
        Libra::register_currency<T>(
            account,
            FixedPoint32::create_from_rational(1, 2), // exchange rate to LBR
            false,   // is_synthetic
            1000000, // scaling_factor = 10^6
            100,     // fractional_part = 10^2
            b"Coin2",
        )
    }
}

}
