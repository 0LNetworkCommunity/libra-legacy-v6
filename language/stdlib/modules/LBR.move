address 0x1 {
/// NB: This module is a stub of the `GAS` at the moment.
///
/// Once the component makeup of the GAS has been chosen the
/// `Reserve` will be updated to hold the backing coins in the correct ratios.

module LBR {
    use 0x1::AccountLimits;
    use 0x1::CoreAddresses;
    use 0x1::Errors;
    use 0x1::FixedPoint32;
    use 0x1::Libra;
    use 0x1::LibraTimestamp;

    /// The type tag representing the `GAS` currency on-chain.
    resource struct GAS { }

    /// Note: Currently only holds the mint, burn, and preburn capabilities for
    /// GAS. Once the makeup of the GAS has been determined this resource will
    /// be updated to hold the backing GAS reserve compnents on-chain.
    ///
    /// The on-chain reserve for the `GAS` holds both the capability for minting `GAS`
    /// coins, and also each reserve component that holds the backing for these coins on-chain.
    /// Currently this holds no coins since GAS is not able to be minted/created.
    resource struct Reserve {
        /// The mint capability allowing minting of `GAS` coins.
        mint_cap: Libra::MintCapability<GAS>,
        /// The burn capability for `GAS` coins. This is used for the unpacking
        /// of `GAS` coins into the underlying backing currencies.
        burn_cap: Libra::BurnCapability<GAS>,
        /// The preburn for `GAS`. This is an administrative field since we
        /// need to alway preburn before we burn.
        preburn_cap: Libra::Preburn<GAS>,
        // TODO: Once the reserve has been determined this resource will
        // contain a ReserveComponent<Currency> for every currency that makes
        // up the reserve.
    }

    /// The `Reserve` resource is in an invalid state
    const ERESERVE: u64 = 0;

    /// Initializes the `GAS` module. This sets up the initial `GAS` ratios and
    /// reserve components, and creates the mint, preburn, and burn
    /// capabilities for `GAS` coins. The `GAS` currency must not already be
    /// registered in order for this to succeed. The sender must both be the
    /// correct address (`CoreAddresses::CURRENCY_INFO_ADDRESS`) and have the
    /// correct permissions (`&Capability<RegisterNewCurrency>`). Both of these
    /// restrictions are enforced in the `Libra::register_currency` function, but also enforced here.
    public fun initialize(
        lr_account: &signer,
        tc_account: &signer,
    ) {
        LibraTimestamp::assert_genesis();
        // Operational constraint
        CoreAddresses::assert_currency_info(lr_account);
        // Reserve must not exist.
        assert(!exists<Reserve>(CoreAddresses::LIBRA_ROOT_ADDRESS()), Errors::already_published(ERESERVE));
        let (mint_cap, burn_cap) = Libra::register_currency<GAS>(
            lr_account,
            FixedPoint32::create_from_rational(1, 1), // exchange rate to GAS
            true,    // is_synthetic
            1000000, // scaling_factor = 10^6
            1000,    // fractional_part = 10^3
            b"GAS"
        );
        // GAS cannot be minted.
        Libra::update_minting_ability<GAS>(tc_account, false);
        AccountLimits::publish_unrestricted_limits<GAS>(lr_account);
        let preburn_cap = Libra::create_preburn<GAS>(tc_account);
        move_to(lr_account, Reserve { mint_cap, burn_cap, preburn_cap });
    }
    spec fun initialize {
       use 0x1::Roles;
        include CoreAddresses::AbortsIfNotCurrencyInfo{account: lr_account};
        aborts_if exists<Reserve>(CoreAddresses::LIBRA_ROOT_ADDRESS()) with Errors::ALREADY_PUBLISHED;
        include Libra::RegisterCurrencyAbortsIf<GAS>{
            currency_code: b"GAS",
            scaling_factor: 1000000
        };
        include AccountLimits::PublishUnrestrictedLimitsAbortsIf<GAS>{publish_account: lr_account};

        include Libra::RegisterCurrencyEnsures<GAS>;
        include Libra::UpdateMintingAbilityEnsures<GAS>{can_mint: false};
        include AccountLimits::PublishUnrestrictedLimitsEnsures<GAS>{publish_account: lr_account};
        ensures exists<Reserve>(CoreAddresses::LIBRA_ROOT_ADDRESS());

        /// Registering GAS can only be done in genesis.
        include LibraTimestamp::AbortsIfNotGenesis;
        /// Only the LibraRoot account can register a new currency [[H8]][PERMISSION].
        include Roles::AbortsIfNotLibraRoot{account: lr_account};
        /// Only the TreasuryCompliance role can update the `can_mint` field of CurrencyInfo [[H2]][PERMISSION].
        /// Moreover, only the TreasuryCompliance role can create Preburn.
        include Roles::AbortsIfNotTreasuryCompliance{account: tc_account};
    }

    /// Returns true if `CoinType` is `GAS::GAS`
    public fun is_lbr<CoinType>(): bool {
        Libra::is_currency<CoinType>() &&
            Libra::currency_code<CoinType>() == Libra::currency_code<GAS>()
    }

    spec fun is_lbr {
        pragma opaque, verify = false;
        include Libra::spec_is_currency<CoinType>() ==> Libra::AbortsIfNoCurrency<GAS>;
        /// The following is correct because currency codes are unique; however, we
        /// can currently not prove it, therefore verify is false.
        ensures result == Libra::spec_is_currency<CoinType>() && spec_is_lbr<CoinType>();
    }

    /// Return the account address where the globally unique GAS::Reserve resource is stored
    public fun reserve_address(): address {
        CoreAddresses::CURRENCY_INFO_ADDRESS()
    }

    // =================================================================
    // Module Specification

    spec module {} // switch documentation context back to module level

    /// # Persistence of Resources

    spec module {
        /// After genesis, the Reserve resource exists.
        invariant [global] LibraTimestamp::is_operating() ==> reserve_exists();

        /// After genesis, GAS is registered.
        invariant [global] LibraTimestamp::is_operating() ==> Libra::is_currency<GAS>();
    }

    /// # Helper Functions
    spec module {
        /// Checks whether the Reserve resource exists.
        define reserve_exists(): bool {
           exists<Reserve>(CoreAddresses::CURRENCY_INFO_ADDRESS())
        }

        /// Returns true if CoinType is GAS.
        define spec_is_lbr<CoinType>(): bool {
            type<CoinType>() == type<GAS>()
        }
    }

}
}
