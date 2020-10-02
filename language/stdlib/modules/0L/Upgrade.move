address 0x0 {

module Upgrade {
    use 0x0::Signer;
    use 0x0::Transaction;

    resource struct UpgradePayload {
        flag: bool,         // may not be necessary
        payload: vector<u8> // TODO: test setting this
    }

    public fun initialize(account: &signer) {
        Transaction::assert(Signer::address_of(account) == 0x0, 0);
        move_to(account, UpgradePayload{flag: false, payload: x""});
    }

    public fun has_upgrade(): bool acquires UpgradePayload {
        if (!exists<UpgradePayload>(0x0)) return false;
        borrow_global<UpgradePayload>(0x0).flag == true
    }

    public fun setUpdate(account: &signer, flag : bool) acquires UpgradePayload {
        Transaction::assert(Signer::address_of(account) == 0x0, 0);
        if (!exists<UpgradePayload>(0x0))
        {
            initialize(account);
        };
        let temp = borrow_global_mut<UpgradePayload>(0x0);
        temp.flag = flag;
    }
}
}
