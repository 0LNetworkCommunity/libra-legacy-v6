// For transferring balance between accounts.
address 0x1 {
module TransferScripts {
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::Globals;
    use 0x1::Signer;

    public(script) fun balance_transfer(
        sender: signer,
        recipient: address,
        unscaled_value: u64,
    ) {
        // IMPORTANT: the human representation of a value is unscaled. The user which expects to send 10 coins, will input that as an unscaled_value. This script converts it to the Move internal scale by multiplying by COIN_SCALING_FACTOR.
        let value = unscaled_value * Globals::get_coin_scaling_factor();
        let sender_addr = Signer::address_of(&sender);
        let sender_balance_pre = DiemAccount::balance<GAS>(sender_addr);
        let recipient_balance_pre = DiemAccount::balance<GAS>(recipient);

        let with_cap = DiemAccount::extract_withdraw_capability(&sender);
        DiemAccount::pay_from<GAS>(&with_cap, recipient, value, b"balance_transfer", b"");
        DiemAccount::restore_withdraw_capability(with_cap);

        assert(DiemAccount::balance<GAS>(recipient) > recipient_balance_pre, 01);
        assert(DiemAccount::balance<GAS>(sender_addr) < sender_balance_pre, 02);
    }

}
}