script {
    use 0x1::AutoPay;
    use 0x1::Signer;
    fun autopay_disable(sender: &signer) {
        let account = Signer::address_of(sender);

        if (AutoPay::is_enabled(account)) {
            AutoPay::disable_autopay(sender);
        };
        assert(AutoPay::is_enabled(account), 0);
    }
}