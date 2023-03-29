/////// 0L /////////

address DiemFramework {

module Testnet {
    ///////////////////////////////////////////////////////////////////////////
    // sets an env variable for test constants for devs and ci testing
    // File Prefix for errors: 2002
    ///////////////////////////////////////////////////////////////////////////
    use Std::Errors;
    use Std::Signer;

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

    // only used for testing purposes
    public fun remove_testnet(account: &signer) acquires IsTestnet {
        assert!(
            Signer::address_of(account) == @DiemRoot,
            Errors::requires_role(200202)
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

    struct IsStagingNet has key { }

    public fun initialize(account: &signer) {
        assert!(
            Signer::address_of(account) == @DiemRoot,
            Errors::requires_role(190301)
        );
        move_to(account, IsStagingNet{})
    }

    public fun is_staging_net(): bool {
        exists<IsStagingNet>(@DiemRoot)
    }

}
}