address 0x1 {

module Upgrade {
    use 0x1::Signer;

    resource struct UpgradePayload {
        flag: bool,         // may not be necessary
        payload: vector<u8> // TODO: test setting this
    }

    public fun initialize(account: &signer) {

        assert(Signer::address_of(account) == 0x1, 0);
        move_to(account, UpgradePayload{flag: false, payload: x""});
    }

    public fun has_upgrade(): bool acquires UpgradePayload {
        if (!exists<UpgradePayload>(0x1)) return false;
        borrow_global<UpgradePayload>(0x1).flag == true
    }

    public fun setUpdate(account: &signer, flag : bool) acquires UpgradePayload {
        assert(Signer::address_of(account) == 0x1, 0);
        if (!exists<UpgradePayload>(0x1))
        {
            initialize(account);
        };
        let temp = borrow_global_mut<UpgradePayload>(0x1);
        temp.flag = flag;
    }
}
}
