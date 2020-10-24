address 0x1 {

module Upgrade {
    use 0x1::Signer;

    resource struct UpgradeInfo {
        flag: bool
    }

    public fun initialize(account: &signer) {
        assert(Signer::address_of(account) == 0x0, 0);
        move_to(account, UpgradeInfo{flag: false});
    }

    public fun has_upgrade(): bool acquires UpgradeInfo {
        if (!exists<UpgradeInfo>(0x0)) return false;
        borrow_global<UpgradeInfo>(0x0).flag == true
    }

    public fun setUpdate(account: &signer, flag : bool) acquires UpgradeInfo {
        assert(Signer::address_of(account) == 0x0, 0);
        if (!exists<UpgradeInfo>(0x0))
        {
            initialize(account);
        };
        let temp = borrow_global_mut<UpgradeInfo>(0x0);
        temp.flag = flag;
    }
}
}
