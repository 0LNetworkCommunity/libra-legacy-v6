address 0x0 {

module Testnet {
    // sets an env variable for test constants for devs and ci testing

    use 0x0::Signer;
    use 0x0::Transaction;

    resource struct IsTestnet { }

    public fun initialize(account: &signer) {
        Transaction::assert(Signer::address_of(account) == 0x0, 0);
        move_to(account, IsTestnet{})
    }

    public fun is_testnet(): bool {
        exists<IsTestnet>(0x0)
    }

    // only used for testing purposes
    public fun remove_testnet(account: &signer)
    acquires IsTestnet {
        Transaction::assert(Signer::address_of(account) == 0x0, 0);
        IsTestnet{} = move_from<IsTestnet>(0x0);
    }
}

module StagingNet {
    // sets an env variable for testing production settings except with shorter epochs and lower vdf difficulty.
    use 0x0::Signer;
    use 0x0::Transaction;

    resource struct IsStagingNet { }

    public fun initialize(account: &signer) {
        Transaction::assert(Signer::address_of(account) == 0x0, 0);
        move_to(account, IsStagingNet{})
    }

    public fun is_staging_net(): bool {
        exists<IsStagingNet>(0x0)
    }

}
}
