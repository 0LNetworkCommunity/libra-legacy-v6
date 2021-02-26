address 0x1 {

module GAS {
    use 0x1::AccountLimits;
    use 0x1::Diem;
    use 0x1::DiemTimestamp;
    use 0x1::FixedPoint32;
  
    struct GAS { }

    public fun initialize(
        lr_account: &signer,
        // tc_account: &signer,
    ) {
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