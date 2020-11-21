address 0x1 {

module Testnet {
    // sets an env variable for test constants for devs and ci testing

    use 0x1::Signer;
    use 0x1::CoreAddresses;

    resource struct IsTestnet { }

    public fun initialize(account: &signer) {
        assert(Signer::address_of(account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 0);
        move_to(account, IsTestnet{})
    }

    public fun is_testnet(): bool {
        exists<IsTestnet>(CoreAddresses::LIBRA_ROOT_ADDRESS())
    }

    // only used for testing purposes
    public fun remove_testnet(account: &signer)
    acquires IsTestnet {
        assert(Signer::address_of(account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 0);
        IsTestnet{} = move_from<IsTestnet>(CoreAddresses::LIBRA_ROOT_ADDRESS());
    }
}

module StagingNet {
    // sets an env variable for testing production settings except with shorter epochs and lower vdf difficulty.
    use 0x1::Signer;
    use 0x1::CoreAddresses;

    resource struct IsStagingNet { }

    public fun initialize(account: &signer) {
        assert(Signer::address_of(account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 0);
        move_to(account, IsStagingNet{})
    }

    public fun is_staging_net(): bool {
        exists<IsStagingNet>(CoreAddresses::LIBRA_ROOT_ADDRESS())
    }

}
}