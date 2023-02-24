/////// 0L /////////

address DiemFramework {

module Testnet {
    ///////////////////////////////////////////////////////////////////////////
    // sets an env variable for test constants for devs and ci testing
    // File Prefix for errors: 2002
    ///////////////////////////////////////////////////////////////////////////
    use Std::Errors;
    use Std::Signer;

    const ENOT_TESTNET: u64 = 666; // out satan!
    const EWHY_U_NO_ROOT: u64 = 667;

    struct IsTestnet has key { }

    public fun initialize(account: &signer) {
        assert!(
            Signer::address_of(account) == @DiemRoot,
            Errors::requires_role(200201)
        );
        move_to(account, IsTestnet{})
    }

    public fun is_testnet(): bool {
        exists<IsTestnet>(@DiemRoot)
    }

    public fun assert_testnet(vm: &signer): bool {
      assert!(
          Signer::address_of(vm) == @DiemRoot,
          Errors::requires_role(EWHY_U_NO_ROOT)
      );
      assert!(is_testnet(), Errors::invalid_state(ENOT_TESTNET));
      true
    }


    // only used for testing purposes
    public fun remove_testnet(account: &signer) acquires IsTestnet {
        assert!(
            Signer::address_of(account) == @DiemRoot,
            Errors::requires_role(EWHY_U_NO_ROOT)
        );
        IsTestnet{} = move_from<IsTestnet>(@DiemRoot);
    }
}

module StagingNet {
    ///////////////////////////////////////////////////////////////////////////
    // sets an env variable for testing production settings except with 
    // shorter epochs and lower vdf difficulty.
    // File Prefix for errors: 1903
    ///////////////////////////////////////////////////////////////////////////
    use Std::Errors;
    use Std::Signer;

    const EWHY_U_NO_ROOT: u64 = 667;
    struct IsStagingNet has key { }

    public fun initialize(account: &signer) {
        assert!(
            Signer::address_of(account) == @DiemRoot,
            Errors::requires_role(EWHY_U_NO_ROOT)
        );
        move_to(account, IsStagingNet{})
    }

    public fun is_staging_net(): bool {
        exists<IsStagingNet>(@DiemRoot)
    }

}
}