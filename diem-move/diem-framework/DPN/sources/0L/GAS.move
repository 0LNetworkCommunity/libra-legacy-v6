address DiemFramework {

/// # Summary 
/// Code to instantiate the GAS token 
/// This is uninteresting, you may be looking for Diem.move
module GAS {
    use DiemFramework::AccountLimits;
    use DiemFramework::Diem;
    use DiemFramework::DiemTimestamp;
    use Std::FixedPoint32;
    use DiemFramework::Roles;
  
    struct GAS has store { }

    /// Called by root in genesis to initialize the GAS coin 
    public fun initialize(
        lr_account: &signer,
        // tc_account: &signer,
    ) {
        Roles::assert_diem_root(lr_account);
        DiemTimestamp::assert_genesis();
        Diem::register_SCS_currency<GAS>(
            lr_account,
            FixedPoint32::create_from_rational(1, 1), // exchange rate to GAS
            1000000, // scaling_factor = 10^6
            1000,     // fractional_part = 10^3
            b"GAS"
        );
        AccountLimits::publish_unrestricted_limits<GAS>(lr_account);
    }
}
}