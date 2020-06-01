address 0x0 {

module GAS {
    use 0x0::FixedPoint32;
    use 0x0::Libra;
    // use 0x0::Transaction;

    // The type tag for this coin type.
    resource struct T { }

    // A reserve component holds one part of the LBR. It holds
    // both backing currency itself, along with the ratio of the backing
    // asset to the LBR (i.e. 1Coin1 to 1LBR ~> ratio = 1).
    resource struct ReserveComponent<CoinType> {
        // Specifies the relative ratio between `CoinType` and LBR (i.e. how
        // many `CoinType`s makeup one LBR).
        ratio: FixedPoint32::T,
        backing: Libra::T<CoinType>
    }

    // The reserve for the LBR holds both the capability of minting LBR
    // coins, and also each reserve component that backs these coins
    // on-chain.
    resource struct Reserve {
        mint_cap: Libra::MintCapability<T>,
        burn_cap: Libra::BurnCapability<T>,
        preburn_cap: Libra::Preburn<T>
    }

    // Initialize the LBR module. This sets up the initial LBR ratios, and
    // creates the mint capability for LBR coins. The LBR currency must not
    // already be registered in order for this to succeed. The sender must
    // both be the correct address and have the correct permissions. These
    // restrictions are enforced in the Libra::register_currency function.
    public fun initialize() {
        // Register the LBR currency.
        Libra::register_currency<T>(
            FixedPoint32::create_from_rational(1, 1), // exchange rate to LBR
            true,    // is_synthetic
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
