script {
    use 0x1::Debug::print;
    use 0x1::AutoPay;
    use 0x1::Signer;
    fun enable_autopay_tx(sender: &signer) {
        print(&0x0000000000000000000000000011e110); // Hello!
        AutoPay::enable_autopay(sender);
        assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    }
}