// For transferring balance between accounts.
address DiemFramework {
module TransferScripts {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Globals;
    use Std::Signer;
    use DiemFramework::Wallet;

    public(script) fun balance_transfer(
        sender: signer,
        destination: address,
        unscaled_value: u64,
    ) {
        // IMPORTANT: the human representation of a value is unscaled. 
        // The user which expects to send 10 coins, will input that as an
        // unscaled_value. This script converts it to the Move internal scale
        // by multiplying by COIN_SCALING_FACTOR.
        let value = unscaled_value * Globals::get_coin_scaling_factor();
        let sender_addr = Signer::address_of(&sender);
        let sender_balance_pre = DiemAccount::balance<GAS>(sender_addr);
        let destination_balance_pre = DiemAccount::balance<GAS>(destination);

        let with_cap = DiemAccount::extract_withdraw_capability(&sender);
        DiemAccount::pay_from<GAS>(&with_cap, destination, value, b"balance_transfer", b"");
        DiemAccount::restore_withdraw_capability(with_cap);

        assert!(DiemAccount::balance<GAS>(destination) > destination_balance_pre, 01);
        assert!(DiemAccount::balance<GAS>(sender_addr) < sender_balance_pre, 02);
    }

    public(script) fun community_transfer(
        sender: signer,
        destination: address,
        unscaled_value: u64,
        memo: vector<u8>,
    ) {
        // IMPORTANT: the human representation of a value is unscaled. 
        // The user which expects to send 10 coins, will input that as an 
        // unscaled_value. This script converts it to the Move internal scale
        // by multiplying by COIN_SCALING_FACTOR.
        let value = unscaled_value * Globals::get_coin_scaling_factor();
        let sender_addr = Signer::address_of(&sender);
        assert!(Wallet::is_comm(sender_addr), 0);

        // confirm the destination account has a slow wallet
        // TODO: this check only happens in this script since there's 
        // a circular dependecy issue with DiemAccount and Wallet which impedes
        // checking in Wallet module
        assert!(DiemAccount::is_slow(destination), 1);

        let uid = Wallet::new_timed_transfer(&sender, destination, value, memo);
        assert!(Wallet::transfer_is_proposed(uid), 2);
    }
}
}