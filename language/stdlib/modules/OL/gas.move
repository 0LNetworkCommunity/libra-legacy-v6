address 0x0 {

module GAS {
    use 0x0::FixedPoint32;
    use 0x0::Libra;
    // use 0x0::Transaction;

    // The type tag for this coin type.
    resource struct T { }

    // The reserve for the GAS holds the capability of minting and burning
    // GAS coins.
    resource struct Reserve {
        mint_cap: Libra::MintCapability<T>,
        burn_cap: Libra::BurnCapability<T>,
        preburn_cap: Libra::Preburn<T>
    }

    // Initialize the GAS module. This sets up the initial GAS ratios, and
    // creates the mint capability for GAS coins. The GAS currency must not
    // already be registered in order for this to succeed. The sender must
    // both be the correct address and have the correct permissions. These
    // restrictions are enforced in the Libra::register_currency function.
    public fun initialize() {
        // Register the GAS currency.
        Libra::register_currency<T>(
            FixedPoint32::create_from_rational(1, 1), // exchange rate to LBR
            false,    // is_synthetic
            1000000, // scaling_factor = 10^6
            1000,    // fractional_part = 10^3
            x"474153" // UTF8-encoded "LBR" as a hex string
        );
        let mint_cap = Libra::grant_mint_capability();
        let burn_cap = Libra::grant_burn_capability();
        let preburn_cap = Libra::new_preburn_with_capability(&burn_cap);
        move_to_sender(Reserve{ mint_cap, burn_cap, preburn_cap});
    }
}

}
