address DiemFramework {
module AutoPayScripts {

    use DiemFramework::AutoPay;
    use Std::Signer;
    use Std::Errors;

    const EAUTOPAY_NOT_ENABLED: u64 = 01001;

    public(script) fun autopay_enable(sender: signer) {
        let account = Signer::address_of(&sender);

        if (!AutoPay::is_enabled(account)) {
            AutoPay::enable_autopay(&sender);
        };
        assert!(AutoPay::is_enabled(account), 0);
    }

    public(script) fun autopay_disable(sender: signer) {
        let account = Signer::address_of(&sender);

        if (AutoPay::is_enabled(account)) {
            AutoPay::disable_autopay(&sender);
        };
        assert!(!AutoPay::is_enabled(account), 010001);
    }

    public(script) fun autopay_create_instruction(
        sender: signer,
        uid: u64,
        in_type: u8,
        payee: address,
        end_epoch: u64,
        value: u64,
    ) {
        let account = Signer::address_of(&sender);
        if (!AutoPay::is_enabled(account)) {
            AutoPay::enable_autopay(&sender);
            assert!(
                AutoPay::is_enabled(account), 
                Errors::invalid_state(EAUTOPAY_NOT_ENABLED)
            );
        };
        
        AutoPay::create_instruction(
            &sender, 
            uid,
            in_type,
            payee,
            end_epoch,
            value,
        );
    }

}
}