address 0x0 {

module GAS {
    use 0x0::FixedPoint32;
    use 0x0::Libra;
    use 0x0::Transaction;
    use 0x0::Signer;

    // The type tag for this coin type.
    resource struct T { }

    // The reserve for the LBR holds both the capability of minting LBR
    // coins, and also each reserve component that backs these coins
    // on-chain.
    resource struct Reserve {
        mint_cap: Libra::MintCapability<T>,
        burn_cap: Libra::BurnCapability<T>,
        preburn_cap: Libra::Preburn<T>,
    }

    // Initialize the LBR module. This sets up the initial LBR ratios, and
    // creates the mint capability for LBR coins. The LBR currency must not
    // already be registered in order for this to succeed. The sender must
    // both be the correct address and have the correct permissions. These
    // restrictions are enforced in the Libra::register_currency function.
    public fun initialize(account: &signer) {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 8001);

      // Register the LBR currency.
      let (mint_cap, burn_cap) = Libra::register_currency<T>(
          account,
          FixedPoint32::create_from_rational(1, 1), // exchange rate to LBR
          false,    // is_synthetic
          1000000, // scaling_factor = 10^6
          1000,    // fractional_part = 10^3
          b"GAS"
      );

      // NOTE: 0L does not neet a preburn capability.
      let preburn_cap = Libra::new_preburn_with_capability(&burn_cap);
      move_to(account, Reserve { mint_cap, burn_cap, preburn_cap });
    }
}
}
