//! account: alice, 1000000, 0, validator

// Test audit function val_audit_passing having not enough balance
//! new-transaction
//! sender: libraroot
//! execute-as: alice
script {
    use 0x1::Audit;
    // use 0x1::Signer;
    use 0x1::ValidatorConfig;
    use 0x1::AutoPay2;
    use 0x1::MinerState;
    use 0x1::GAS::GAS;
    use 0x1::LibraAccount;
    
    fun main(lr: &signer, alice_account: &signer) {
        // enable autopay
        AutoPay2::enable_autopay(alice_account);
        assert(AutoPay2::is_enabled({{alice}}), 1);
        assert(ValidatorConfig::is_valid({{alice}}), 1);
        assert(MinerState::is_init({{alice}}), 1);
        
        // check operator zero balance
        let oper = ValidatorConfig::get_operator({{alice}});
        assert(LibraAccount::balance<GAS>(oper) == 0, 1);        
        assert(!Audit::val_audit_passing({{alice}}), 1);

        // transfer not enough balance to operator
        let oper = ValidatorConfig::get_operator({{alice}});
        LibraAccount::vm_make_payment_no_limit<GAS>(
            {{alice}},
            oper,
            49999,
            x"",
            x"",
            lr
        );
        assert(LibraAccount::balance<GAS>(oper) == 49999, 1);
        assert(!Audit::val_audit_passing({{alice}}), 1);
    }
}
// check: EXECUTED
