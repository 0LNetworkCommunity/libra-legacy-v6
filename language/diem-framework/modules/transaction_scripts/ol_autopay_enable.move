address 0x1 {
module AutoPayScripts {

    use 0x1::AutoPay2;
    use 0x1::Signer;
    
    public(script) fun autopay_enable(sender: signer) {
        let account = Signer::address_of(&sender);

        if (!AutoPay2::is_enabled(account)) {
            AutoPay2::enable_autopay(&sender);
        };
        assert(AutoPay2::is_enabled(account), 0);
    }

}
}