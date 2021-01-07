script {
    use 0x1::AutoPay;
    use 0x1::Signer;
    fun autopay_enable(sender: &signer) {
        AutoPay::enable_autopay(sender);
        assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    }
}