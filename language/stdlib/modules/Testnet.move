address 0x0 {

module Testnet {
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
}
